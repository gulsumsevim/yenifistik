import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageUploadService {
  static const String uploadUrl = 'http://fruitmanagement.softsense.com.tr/api/PictureAi/UploadImageWithoutIdForUser';

  static Future<http.StreamedResponse> uploadImage(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var stream = http.ByteStream(imageFile.openRead().cast());
    var length = await imageFile.length();

    var uri = Uri.parse(uploadUrl);

    var request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        http.MultipartFile(
          'formFile',
          stream,
          length,
          filename: basename(imageFile.path),
        ),
      );

    return await request.send();
  }
}
