import 'package:flutter/material.dart';
import 'package:fistikpazar/models/lands_model.dart';
import 'package:fistikpazar/services/lands_services.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.field.name);
    _addressController = TextEditingController(text: widget.field.address);
    _areaController = TextEditingController(text: widget.field.area.toString());
    _numberOfTreeController = TextEditingController(text: widget.field.numberOfTree.toString());
    _locationController = TextEditingController(text: widget.field.location);
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
    String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=${_locationController.text}";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Harita açılamıyor')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Araziyi Düzenle'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            ElevatedButton(
              onPressed: _showLocation,
              child: Text('Lokasyonu Gör'),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
