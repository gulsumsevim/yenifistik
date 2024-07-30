import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class DigitalAdvisorScreen extends StatefulWidget {
  @override
  _DigitalAdvisorScreenState createState() => _DigitalAdvisorScreenState();
}

class _DigitalAdvisorScreenState extends State<DigitalAdvisorScreen> {
  File? _selectedImage;
  String? _responseMessage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImageAndGetProblem() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final uploadResponse = await _uploadImage();
      if (uploadResponse != null && uploadResponse.containsKey('imageUrl')) {
        final imageUrl = uploadResponse['imageUrl'];
        print('Image URL: $imageUrl'); // URL'yi kontrol etmek için ekledik
        final problemResponse = await _getProblemFromAi(imageUrl);

        setState(() {
          _responseMessage = problemResponse;
        });
      } else {
        setState(() {
          _responseMessage = "Resim yükleme başarısız.";
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = "AI problem analizi başarısız: Exception: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _uploadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("Token not found");
    }

    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/PictureAi/UploadImageWithoutIdForUser'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['accept'] = '*/*';

    var pic = await http.MultipartFile.fromPath(
      "formFile",
      _selectedImage!.path,
      contentType: MediaType('image', 'jpeg'),
    );

    request.files.add(pic);

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      print('Response Data: $responseData'); // Bu satırı ekleyerek responseData'nın içeriğini kontrol edin
      return jsonDecode(responseData);
    } else {
      var responseData = await response.stream.bytesToString();
      print('Resim yükleme başarısız: ${response.statusCode}');
      print('Response body: $responseData');
      return null;
    }
  }

  Future<String> _getProblemFromAi(String imageUrl) async {
    final requestBody = jsonEncode({
      "model": "gpt-4",
      "messages": [
        {
          "role": "user",
          "content": "Bu resimdeki bitkinin ne gibi bir sorunu var? \n\n![Resim]($imageUrl)"
        }
      ],
    });

    print('Request Body: $requestBody'); // Gönderilen veriyi kontrol etmek için ekledik

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer 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', // API anahtarınızı buraya ekleyin
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      print('Response Data from AI: $data'); // OpenAI API'sinin yanıtını kontrol edin
      return data['choices'][0]['message']['content'];
    } else {
      print('AI image problem request failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('AI image problem request failed: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dijital Danışman'),
        backgroundColor: Color.fromARGB(255, 255, 240, 219),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      margin: EdgeInsets.all(16.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _selectedImage == null
                                ? Text('Resim seçilmedi.')
                                : Image.file(_selectedImage!),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: Text('Resim Seç'),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _uploadImageAndGetProblem,
                              child: Text('Sorunu Bul'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_responseMessage != null)
                      Card(
                        margin: EdgeInsets.all(16.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Text(
                              _responseMessage!,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
