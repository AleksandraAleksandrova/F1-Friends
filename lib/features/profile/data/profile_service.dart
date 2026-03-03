import "package:image_picker/image_picker.dart";

import "../domain/app_user.dart";

abstract class ProfileService {
  Stream<AppUser?> watchUser(String uid);

  Future<void> ensureUserDocument({
    required String uid,
    required String email,
  });

  Future<void> updateUsername({
    required String uid,
    required String username,
  });

  Future<void> updateProfileImage({
    required String uid,
    required ImageSource source,
  });
}
