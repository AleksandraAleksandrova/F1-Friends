class AppUser {
  final String id;
  final String username;
  final String email;
  final String? displayName;
  final String? profileImageUrl;

  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "username": username,
      "email": email,
      "displayName": displayName,
      "profileImageUrl": profileImageUrl,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map["id"] as String,
      username: map["username"] as String,
      email: map["email"] as String,
      displayName: map["displayName"] as String?,
      profileImageUrl: map["profileImageUrl"] as String?,
    );
  }
}
