import "package:flutter/material.dart";

import "features/auth/presentation/auth_screen.dart";

class F1FriendsApp extends StatelessWidget {
  const F1FriendsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "F1 Friends",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}
