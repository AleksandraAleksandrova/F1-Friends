import "package:cloud_firestore/cloud_firestore.dart";

class AppUser {
  final String id;
  final String username;
  final String email;
  final String? displayName;
  final String? profileImageUrl;
  final DateTime? joinedAt;

  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.profileImageUrl,
    this.joinedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "username": username,
      "email": email,
      "displayName": displayName,
      "profileImageUrl": profileImageUrl,
      "joinedAt": joinedAt?.toUtc().toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    final email = (map["email"] as String?) ?? "";
    final fallbackUsername = email.contains("@") ? email.split("@").first : "driver";
    final rawCreated = map["createdAt"] ?? map["joinedAt"];
    DateTime? joinedAt;
    if (rawCreated is Timestamp) {
      joinedAt = rawCreated.toDate().toUtc();
    } else if (rawCreated is String) {
      joinedAt = DateTime.tryParse(rawCreated)?.toUtc();
    }
    return AppUser(
      id: map["id"] as String,
      username: (map["username"] as String?) ?? fallbackUsername,
      email: email,
      displayName: (map["displayName"] as String?) ?? (map["username"] as String?) ?? fallbackUsername,
      profileImageUrl: map["profileImageUrl"] as String?,
      joinedAt: joinedAt,
    );
  }
}
