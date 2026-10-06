import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'image_storage_data_source.dart';

class CloudinaryImageStorageDataSource
    implements ImageStorageDataSource {
  static const String _cloudName = 'ypm25lyf';
  static const String _uploadPreset = 'taskflow_profile';

  @override
  Future<String> uploadImage({
    required String userId,
    required String filePath,
  }) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('Image file not found.');
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = _uploadPreset;
    request.fields['folder'] = 'taskflow/profile_images/$userId';

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
      ),
    );

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Cloudinary upload failed: ${response.statusCode}',
      );
    }

    final data = jsonDecode(responseBody) as Map<String, dynamic>;

    final secureUrl = data['secure_url'] as String?;

    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary did not return an image URL.');
    }

    return secureUrl;
  }
}