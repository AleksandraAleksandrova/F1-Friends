import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../leagues/providers/leagues_providers.dart";
import "../data/mock_scoring_service.dart";

final mockScoringServiceProvider = Provider<MockScoringService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return MockScoringService(firestore);
});
