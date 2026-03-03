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
    return _firestore.doc(FirestorePaths.user(userId)).snapshots().asyncMap((userSnap) async {
      final data = userSnap.data();
      final leagueIds = (data?["joinedLeagueIds"] as List?)
              ?.whereType<String>()
              .toSet()
              .toList() ??
          <String>[];
      if (leagueIds.isEmpty) {
        return <League>[];
      }

      final leagues = <League>[];
      for (final leagueId in leagueIds) {
        final doc = await _firestore.doc(FirestorePaths.league(leagueId)).get();
        if (!doc.exists) {
          continue;
        }
        leagues.add(
          League.fromMap({
            "id": doc.id,
            ...doc.data()!,
          }),
        );
      }

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
      throw StateError("End round must be >= start round.");
    }

    final joinCode = await _generateUniqueJoinCode();
    final leagueRef = _firestore.collection(FirestorePaths.leagues).doc();
    final joinCodeRef = _firestore.doc(FirestorePaths.leagueJoinCode(joinCode));
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
    batch.set(joinCodeRef, {
      "joinCode": joinCode,
      "leagueId": leagueRef.id,
      "createdAt": FieldValue.serverTimestamp(),
    });
    batch.set(memberRef, {
      "userId": userId,
      "joinedAt": FieldValue.serverTimestamp(),
      "role": "admin",
      "totalPoints": 0,
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
    final codeDoc = await _firestore.doc(FirestorePaths.leagueJoinCode(normalizedCode)).get();
    if (!codeDoc.exists) {
      throw StateError("League with this join code was not found.");
    }
    final codeData = codeDoc.data()!;
    final leagueId = codeData["leagueId"] as String?;
    if (leagueId == null || leagueId.isEmpty) {
      throw StateError("Join code mapping is invalid.");
    }
    final leagueRef = _firestore.doc(FirestorePaths.league(leagueId));
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
          "totalPoints": 0,
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

  @override
  Future<void> deleteLeague({
    required String userId,
    required String leagueId,
  }) async {
    final leagueRef = _firestore.doc(FirestorePaths.league(leagueId));
    final leagueSnap = await leagueRef.get();
    if (!leagueSnap.exists) {
      return;
    }
    final data = leagueSnap.data()!;
    final adminUserId = data["adminUserId"] as String?;
    if (adminUserId != userId) {
      throw StateError("Only league admin can delete this league.");
    }
    final joinCode = (data["joinCode"] as String?) ?? "";

    final memberDocs = await leagueRef.collection("members").get();
    final batch = _firestore.batch();
    for (final memberDoc in memberDocs.docs) {
      final memberUid = (memberDoc.data()["userId"] as String?) ?? memberDoc.id;
      if (memberUid.isNotEmpty) {
        batch.set(
          _firestore.doc(FirestorePaths.user(memberUid)),
          {
            "joinedLeagueIds": FieldValue.arrayRemove([leagueId]),
            "updatedAt": FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
      batch.delete(memberDoc.reference);
    }

    if (joinCode.isNotEmpty) {
      batch.delete(_firestore.doc(FirestorePaths.leagueJoinCode(joinCode)));
    }
    batch.delete(leagueRef);
    await batch.commit();
  }

  Future<String> _generateUniqueJoinCode() async {
    const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    for (var i = 0; i < 12; i++) {
      final code = List.generate(6, (_) => alphabet[_random.nextInt(alphabet.length)]).join();
      final existing = await _firestore.doc(FirestorePaths.leagueJoinCode(code)).get();
      if (!existing.exists) {
        return code;
      }
    }
    throw StateError("Could not generate a unique join code. Please retry.");
  }
}
