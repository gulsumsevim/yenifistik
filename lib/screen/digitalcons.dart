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

    var pic = await http.MultipartFile.fromPath(
      "formFile",
      _selectedImage!.path,
      contentType: MediaType('image', 'jpeg'), // uygun content type belirtin
    );

    request.files.add(pic);

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      print('Response Data: $responseData'); // Bu satırı ekleyerek responseData'nın içeriğini kontrol edin
      return jsonDecode(responseData);
    } else {
      print('Resim yükleme başarısız: ${response.statusCode}');
      return null;
    }
  }

  Future<String> _getProblemFromAi(String imageUrl) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer YOUR_OPENAI_API_KEY', // API anahtarınızı buraya ekleyin
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4-turbo",
        "messages": [
          {
            "role": "user",
            "content": "Bu resimdeki bitkinin ne gibi bir sorunu var? Nasıl düzeltebilirim? neden böyle oldu? bir daha böyle olmaması için ne gibi önlemler almalıyım? tüm sorularımı tek tek cevapla. \n\n![Resim]($imageUrl)"
          }
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['choices'][0]['message']['content'];
    } else {
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
                    _selectedImage == null
                        ? Text('Resim seçilmedi.')
                        : Image.file(_selectedImage!),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Resim Seç'),
                    ),
                    ElevatedButton(
                      onPressed: _uploadImageAndGetProblem,
                      child: Text('Sorunu Bul'),
                    ),
                    SizedBox(height: 20),
                    _responseMessage == null
                        ? Text('AI cevabı burada görünecek.')
                        : Container(
                            padding: const EdgeInsets.all(16.0),
                            child: SingleChildScrollView(
                              child: Text(
                                _responseMessage!,
                                style: TextStyle(fontSize: 14),
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
