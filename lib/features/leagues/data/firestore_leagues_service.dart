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
        .snapshots()
        .asyncMap((leagueSnap) async {
      if (leagueSnap.docs.isEmpty) {
        return <League>[];
      }

      final membershipChecks = await Future.wait(
        leagueSnap.docs.map((leagueDoc) async {
          final memberDoc = await leagueDoc.reference.collection("members").doc(userId).get();
          if (!memberDoc.exists || leagueDoc.data().isEmpty) {
            return null;
          }
          return League.fromMap({
            "id": leagueDoc.id,
            ...leagueDoc.data(),
          });
        }),
      );
      final leagues = membershipChecks.whereType<League>().toList();

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

    for (var attempt = 0; attempt < 8; attempt++) {
      final joinCode = _generateJoinCode();
      final leagueRef = _firestore.collection(FirestorePaths.leagues).doc();
      final joinCodeRef = _firestore.doc(FirestorePaths.leagueJoinCode(joinCode));
      final memberRef = leagueRef.collection("members").doc(userId);

      try {
        await _firestore.runTransaction((tx) async {
          final existingCode = await tx.get(joinCodeRef);
          if (existingCode.exists) {
            throw StateError("join-code-collision");
          }

          tx.set(leagueRef, {
            "name": input.name.trim(),
            "joinCode": joinCode,
            "adminUserId": userId,
            "seasonYear": input.seasonYear,
            "startRound": input.startRound,
            "endRound": input.endRound,
            "scoringLocked": true,
            "memberCount": 1,
            "scoringRules": input.scoringRules.toMap(),
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
          });
          tx.set(joinCodeRef, {
            "joinCode": joinCode,
            "leagueId": leagueRef.id,
            "createdAt": FieldValue.serverTimestamp(),
          });
          tx.set(memberRef, {
            "userId": userId,
            "joinedAt": FieldValue.serverTimestamp(),
            "role": "admin",
            "totalPoints": 0,
          });
        });
        return leagueRef.id;
      } on StateError catch (error) {
        if (error.message != "join-code-collision") {
          rethrow;
        }
      }
    }

    throw StateError("Could not generate a unique join code. Please retry.");
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

    final result = await _firestore.runTransaction<JoinLeagueResult>((tx) async {
      final leagueSnap = await tx.get(leagueRef);
      if (!leagueSnap.exists) {
        throw StateError("League was not found.");
      }
      final memberSnap = await tx.get(memberRef);
      final alreadyMember = memberSnap.exists;

      if (!alreadyMember) {
        tx.update(leagueRef, {
          "memberCount": FieldValue.increment(1),
          "updatedAt": FieldValue.serverTimestamp(),
        });
        tx.set(memberRef, {
          "userId": userId,
          "joinedAt": FieldValue.serverTimestamp(),
          "role": "member",
          "totalPoints": 0,
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
      batch.delete(memberDoc.reference);
    }

    if (joinCode.isNotEmpty) {
      batch.delete(_firestore.doc(FirestorePaths.leagueJoinCode(joinCode)));
    }
    batch.delete(leagueRef);
    await batch.commit();
  }

  String _generateJoinCode() {
    const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    return List.generate(6, (_) => alphabet[_random.nextInt(alphabet.length)]).join();
  }
}
