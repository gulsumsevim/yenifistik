import 'package:flutter/material.dart';
import 'package:fistikpazar/models/lands_model.dart';
import 'package:fistikpazar/services/lands_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Image data model
class ImageData {
  final String url;
  final String fileName;

  ImageData({required this.url, required this.fileName});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      url: json['url'],
      fileName: json['fileName'],
    );
  }
}

class LandsScreen extends StatefulWidget {
  @override
  _LandsScreenState createState() => _LandsScreenState();
}

class _LandsScreenState extends State<LandsScreen> {
  late Future<List<FieldInfo>> futureFields;

  @override
  void initState() {
    super.initState();
    futureFields = FieldService.getFields();
  }

  void _navigateToEditFieldPage(FieldInfo field) async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFieldPage(field: field),
      ),
    );

    if (result != null && result) {
      setState(() {
        futureFields = FieldService.getFields();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Arazilerim'),
      ),
      body: FutureBuilder<List<FieldInfo>>(
        future: futureFields,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Araziler bulunamadı.'));
          } else {
            List<FieldInfo> fields = snapshot.data!;
            return ListView.builder(
              itemCount: fields.length,
              itemBuilder: (context, index) {
                FieldInfo field = fields[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: ListTile(
                      title: Text(
                        field.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Adres: ${field.address}', style: TextStyle(fontSize: 16)),
                          Text('Alan: ${field.area} m²', style: TextStyle(fontSize: 16)),
                          Text('Ağaç Sayısı: ${field.numberOfTree}', style: TextStyle(fontSize: 16)),
                          Text('Lokasyon: ${field.location}', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      onTap: () {
                        _navigateToEditFieldPage(field);
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class EditFieldPage extends StatefulWidget {
  final FieldInfo field;

  EditFieldPage({required this.field});

  @override
  _EditFieldPageState createState() => _EditFieldPageState();
}

class _EditFieldPageState extends State<EditFieldPage> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _areaController;
  late TextEditingController _numberOfTreeController;
  late TextEditingController _locationController;

  late Future<List<ImageData>> futureImages;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.field.name);
    _addressController = TextEditingController(text: widget.field.address);
    _areaController = TextEditingController(text: widget.field.area.toString());
    _numberOfTreeController = TextEditingController(text: widget.field.numberOfTree.toString());
    _locationController = TextEditingController(text: widget.field.location);

    futureImages = fetchImages();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _numberOfTreeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<List<ImageData>> fetchImages() async {
    final response = await http.get(Uri.parse('https://api.fistikpazar.com/api/Farmer/list'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ImageData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load images');
    }
  }

  void _updateField() async {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _areaController.text.isEmpty ||
        _numberOfTreeController.text.isEmpty ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lütfen tüm alanları doldurun')));
      return;
    }

    final updatedField = FieldInfo(
      userId: widget.field.userId,
      fieldId: widget.field.fieldId,
      name: _nameController.text,
      address: _addressController.text,
      area: int.parse(_areaController.text),
      numberOfTree: int.parse(_numberOfTreeController.text),
      location: _locationController.text,
      createdDate: widget.field.createdDate,
    );

    try {
      await FieldService.updateField(updatedField);
      Navigator.of(context).pop(true);
    } catch (e) {
      print('Hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Güncelleme başarısız oldu')));
    }
  }

  void _showLocation() async {
    final location = widget.field.location;
    final url = _getMapsUrl(location);

    print(url); // Oluşturulan URL'yi terminalde yazdırarak doğrulayın.

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('URL açma işlemi gerçekleştirilemiyor: $url')));
      }
    }
  }

  String _getMapsUrl(String location) {
    final coordinatesRegex = RegExp(r'^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?),\s*[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$');

    if (coordinatesRegex.hasMatch(location)) {
      // Location is coordinates (latitude, longitude)
      return 'https://www.google.com/maps/search/?api=1&query=${location}';
    } else {
      // Location is an address
      return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Araziyi Düzenle'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Adı'),
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Adres'),
              ),
              TextField(
                controller: _areaController,
                decoration: InputDecoration(labelText: 'Alan (m²)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _numberOfTreeController,
                decoration: InputDecoration(labelText: 'Ağaç Sayısı'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Lokasyon'),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _updateField,
                    child: Text('Kaydet'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('İptal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                  ),
              /*    ElevatedButton(
                    onPressed: _showLocation,
                    child: Text('Konumu Gör'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),*/
                ],
              ),
              SizedBox(height: 20),
              FutureBuilder<List<ImageData>>(
                future: futureImages,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Resimler bulunamadı.'));
                  } else {
                    List<ImageData> images = snapshot.data!;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        ImageData image = images[index];
                        return GestureDetector(
                          onTap: () {
                            // Resme tıklanınca yapılacak işlem
                          },
                          child: GridTile(
                            child: Image.network(
                              image.url,
                              fit: BoxFit.cover,
                            ),
                            footer: GridTileBar(
                              backgroundColor: Colors.black54,
                              title: Text(image.fileName),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: LandsScreen(),
));
