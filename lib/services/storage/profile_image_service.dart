import "package:firebase_storage/firebase_storage.dart";
import "package:image_picker/image_picker.dart";

class ProfileImageService {
  final FirebaseStorage _storage;
  final ImagePicker _picker;

  ProfileImageService(this._storage, this._picker);

  Future<XFile?> pickFromCamera() => _picker.pickImage(source: ImageSource.camera);

  Future<XFile?> pickFromGallery() => _picker.pickImage(source: ImageSource.gallery);

  Future<String> uploadProfileImage({required String userId, required XFile file}) async {
    final ref = _storage.ref("profileImages/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg");
    final bytes = await file.readAsBytes();
    await ref.putData(bytes);
    return ref.getDownloadURL();
  }
}
