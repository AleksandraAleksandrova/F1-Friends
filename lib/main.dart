import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "app.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // For Android, google-services.json is the source of Firebase config.
    await Firebase.initializeApp();
  } on FirebaseException catch (e) {
    // Hot restart or duplicate init path: reuse existing default app.
    if (e.code != "duplicate-app") {
      rethrow;
    }
    Firebase.app();
  }
  runApp(const ProviderScope(child: F1FriendsApp()));
}
