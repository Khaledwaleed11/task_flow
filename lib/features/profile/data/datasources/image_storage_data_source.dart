abstract class ImageStorageDataSource {
  Future<String> uploadImage({
    required String userId,
    required String filePath,
  });
}