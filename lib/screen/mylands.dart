import 'package:fistikpazar/screen/land_detail.dart';
import 'package:flutter/material.dart';
import 'package:fistikpazar/models/lands_model.dart';
import 'package:fistikpazar/services/lands_services.dart';

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

  void _showEditFieldDialog(FieldInfo field) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(10),
        backgroundColor: Colors.transparent,
        child: EditFieldPage(field: field),
      ),
    ).then((value) {
      if (value != null && value == true) {
        setState(() {
          futureFields = FieldService.getFields();
        });
      }
    });
  }

  void _showAddFieldDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(10),
        backgroundColor: Colors.transparent,
        child: AddFieldPage(),
      ),
    ).then((value) {
      if (value != null && value == true) {
        setState(() {
          futureFields = FieldService.getFields();
        });
      }
    });
  }

  void _deleteField(int fieldId) async {
    try {
      await FieldService.deleteField(fieldId);
      setState(() {
        futureFields = FieldService.getFields();
      });
    } catch (e) {
      print('Hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Silme işlemi başarısız oldu')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 240, 219),
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
                    color: _getColor(index),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      title: Text(
                        field.name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Adres: ${field.address}'),
                          SizedBox(height: 5),
                          Text('Alan: ${field.area} m²'),
                          Text('Ağaç Sayısı: ${field.numberOfTree}'),
                         
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteField(field.fieldId),
                      ),
                      onTap: () {
                        _showEditFieldDialog(field);
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFieldDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getColor(int index) {
    final colors = [
      Colors.amber[100],
      Colors.green[100],
      Colors.blue[100],
    ];
    return colors[index % colors.length]!;
  }
}

class AddFieldPage extends StatefulWidget {
  @override
  _AddFieldPageState createState() => _AddFieldPageState();
}

class _AddFieldPageState extends State<AddFieldPage> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _areaController;
  late TextEditingController _numberOfTreeController;
  late TextEditingController _locationController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _areaController = TextEditingController();
    _numberOfTreeController = TextEditingController();
    _locationController = TextEditingController();
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

  void _addField() async {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _areaController.text.isEmpty ||
        _numberOfTreeController.text.isEmpty ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lütfen tüm alanları doldurun')));
      return;
    }

    final newField = FieldInfo(
      userId: 0, // Bunu uygun bir değere ayarlamanız gerekebilir
      fieldId: 0, // Bu alan veritabanı tarafından oluşturulacak
      name: _nameController.text,
      address: _addressController.text,
      area: int.parse(_areaController.text),
      numberOfTree: int.parse(_numberOfTreeController.text),
      location: _locationController.text,
      createdDate: DateTime.now().toString(),
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await FieldService.addField(newField);
      setState(() {
        _isSaving = false;
      });
      Navigator.of(context).pop(true);
    } catch (e) {
      print('Hata: $e');
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ekleme başarısız oldu')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Arazi Ekle', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
              if (_isSaving)
                CircularProgressIndicator()
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _addField,
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
      ),
    );
  }
}
