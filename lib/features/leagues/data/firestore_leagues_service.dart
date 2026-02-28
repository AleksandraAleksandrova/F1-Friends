import "dart:math";

import "package:cloud_firestore/cloud_firestore.dart";

import "../../../core/constants/firestore_paths.dart";
import "../domain/league.dart";
import "leagues_service.dart";

class FirestoreLeaguesService implements LeaguesService {
  final FirebaseFirestore _firestore;
  final Random _random;

  FirestoreLeaguesService(this._firestore) : _random = Random();

  static const defaultScoringRules = ScoringRulesInput(
    pointsP1Exact: 10,
    pointsP2Exact: 8,
    pointsP3Exact: 6,
    pointsFastestLapExact: 4,
    pointsDnfExact: 3,
    pointsBonusAllPodiumExact: 5,
  );

  @override
  Stream<List<League>> watchUserLeagues(String userId) {
    return _firestore
        .collection(FirestorePaths.leagues)
        .where("memberIds", arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final leagues = snapshot.docs.map((doc) {
        final data = doc.data();
        return League.fromMap({
          "id": doc.id,
          ...data,
        });
      }).toList();
      leagues.sort((a, b) => b.seasonYear.compareTo(a.seasonYear));
      return leagues;
    });
  }

  @override
  Future<String> createLeague({
    required String userId,
    required CreateLeagueInput input,
  }) async {
    if (input.startRound > input.endRound) {
      throw StateError("Start round cannot be greater than end round.");
    }

    final joinCode = await _generateUniqueJoinCode();
    final leagueRef = _firestore.collection(FirestorePaths.leagues).doc();
    final memberRef = leagueRef.collection("members").doc(userId);
    final userRef = _firestore.doc(FirestorePaths.user(userId));

    // Many-to-many representation:
    // 1) leagues/{leagueId}/members/{uid}
    // 2) users/{uid}.joinedLeagueIds[]
    // memberIds[] on league is a query helper.
    final batch = _firestore.batch();
    batch.set(leagueRef, {
      "name": input.name.trim(),
      "joinCode": joinCode,
      "adminUserId": userId,
      "seasonYear": input.seasonYear,
      "startRound": input.startRound,
      "endRound": input.endRound,
      "scoringLocked": true,
      "memberCount": 1,
      "memberIds": [userId],
      "scoringRules": input.scoringRules.toMap(),
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });
    batch.set(memberRef, {
      "userId": userId,
      "joinedAt": FieldValue.serverTimestamp(),
      "role": "admin",
    });
    batch.set(userRef, {
      "joinedLeagueIds": FieldValue.arrayUnion([leagueRef.id]),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();

    return leagueRef.id;
  }

  @override
  Future<JoinLeagueResult> joinLeagueByCode({
    required String userId,
    required String joinCode,
  }) async {
    final normalizedCode = joinCode.trim().toUpperCase();
    final query = await _firestore
        .collection(FirestorePaths.leagues)
        .where("joinCode", isEqualTo: normalizedCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw StateError("League with this join code was not found.");
    }

    final leagueRef = query.docs.first.reference;
    final memberRef = leagueRef.collection("members").doc(userId);
    final userRef = _firestore.doc(FirestorePaths.user(userId));

    final result = await _firestore.runTransaction<JoinLeagueResult>((tx) async {
      final leagueSnap = await tx.get(leagueRef);
      final memberIds = List<String>.from((leagueSnap.data()?["memberIds"] ?? const <String>[]));
      final alreadyMember = memberIds.contains(userId);

      if (!alreadyMember) {
        tx.update(leagueRef, {
          "memberIds": FieldValue.arrayUnion([userId]),
          "memberCount": FieldValue.increment(1),
          "updatedAt": FieldValue.serverTimestamp(),
        });
        tx.set(memberRef, {
          "userId": userId,
          "joinedAt": FieldValue.serverTimestamp(),
          "role": "member",
        }, SetOptions(merge: true));
        tx.set(userRef, {
          "joinedLeagueIds": FieldValue.arrayUnion([leagueRef.id]),
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return JoinLeagueResult(leagueId: leagueRef.id, joined: !alreadyMember);
    });

    return result;
  }

  Future<String> _generateUniqueJoinCode() async {
    const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    for (var i = 0; i < 12; i++) {
      final code = List.generate(6, (_) => alphabet[_random.nextInt(alphabet.length)]).join();
      final existing = await _firestore
          .collection(FirestorePaths.leagues)
          .where("joinCode", isEqualTo: code)
          .limit(1)
          .get();
      if (existing.docs.isEmpty) {
        return code;
      }
    }
    throw StateError("Could not generate a unique join code. Please retry.");
  }
}
