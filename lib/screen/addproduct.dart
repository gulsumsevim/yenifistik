import 'dart:io';

import 'package:fistikpazar/models/addproduct_model.dart';
import 'package:fistikpazar/services/addproduct_services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductAddPage extends StatefulWidget {
  @override
  _ProductAddPageState createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _harvestController = TextEditingController();
  String? _selectedCategory;
  String? _selectedProductSize;
  String? _selectedField;
  bool _isLoading = false;
  File? _selectedMainImage; // Ana resim dosyası
  List<File> _selectedExtraImages = []; // Ek resim dosyaları

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> fields = [];
  List<Map<String, dynamic>> productSizes = [
    {"id": 0, "title": "Küçük"},
    {"id": 1, "title": "Orta"},
    {"id": 2, "title": "Büyük"},
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndFields();
  }

  Future<void> _fetchCategoriesAndFields() async {
    try {
      final fetchedCategories = await ApiService.getCategories();
      final fetchedFields = await ApiService.getFields();

      setState(() {
        categories = fetchedCategories;
        fields = fetchedFields;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veriler alınamadı')),
      );
    }
  }

  Future<void> _pickMainImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedMainImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickExtraImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedExtraImages = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      });
    }
  }

  void _handleAddProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final product = Product(
        fieldId: int.parse(_selectedField!),
        categoryId: int.parse(_selectedCategory!),
        status: true,
        productSizeId: int.parse(_selectedProductSize!),
        name: _nameController.text,
        price: double.parse(_priceController.text),
        image: '', // Resim URL'si burada olacak
        harvest: int.parse(_harvestController.text),
        stock: int.parse(_stockController.text),
        description: _descriptionController.text,
      );

      final response = await ApiService.addProduct(product, _selectedMainImage, _selectedExtraImages);

      setState(() {
        _isLoading = false;
      });

      if (response) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ürün eklenemedi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürün Ekle'),
        backgroundColor: Color(0xFFFFF0DB),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Ana resim ekleme bölümü
                    GestureDetector(
                      onTap: _pickMainImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200],
                        ),
                        child: _selectedMainImage == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, color: Colors.green),
                                    Text('Resim Ekle', style: TextStyle(color: Colors.green)),
                                  ],
                                ),
                              )
                            : Image.file(_selectedMainImage!, fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Ürün adı
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Ürün Adı'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen ürün adını girin';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    // Ürün kategorisi
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Ürün Kategorisi'),
                        value: _selectedCategory,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        items: categories.map<DropdownMenuItem<String>>((Map<String, dynamic> value) {
                          return DropdownMenuItem<String>(
                            value: value['id'].toString(),
                            child: Text(value['name']),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Lütfen bir kategori seçin';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    // Ürün fiyatı
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(labelText: 'Ürün Fiyatı'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen ürün fiyatını girin';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    // Ürün boyutu
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Ürün Boyutu'),
                        value: _selectedProductSize,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedProductSize = newValue;
                          });
                        },
                        items: productSizes.map<DropdownMenuItem<String>>((Map<String, dynamic> value) {
                          return DropdownMenuItem<String>(
                            value: value['id'].toString(),
                            child: Text(value['title']),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Lütfen bir ürün boyutu seçin';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    // Arazi adı
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Arazi Adı'),
                        value: _selectedField,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedField = newValue;
                          });
                        },
                        items: fields.map<DropdownMenuItem<String>>((Map<String, dynamic> value) {
                          return DropdownMenuItem<String>(
                            value: value['fieldId'].toString(),
                            child: Text(value['name']),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Lütfen bir arazi seçin';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    // Hasat miktarı
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: TextFormField(
                        controller: _harvestController,
                        decoration: InputDecoration(labelText: 'Hasat Miktarı'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen hasat miktarını girin';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    // Stok miktarı
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: TextFormField(
                        controller: _stockController,
                        decoration: InputDecoration(labelText: 'Stok Miktarı'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen stok miktarını girin';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    // Ürün açıklaması
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: 'Ürün Açıklaması'),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen ürün açıklamasını girin';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    // Ek resimler ekleme bölümü
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: Column(
                        children: [
                          _selectedExtraImages.isEmpty
                              ? Text('Ek resimler seçilmedi.')
                              : Wrap(
                                  spacing: 8.0,
                                  children: _selectedExtraImages.map((file) {
                                    return Image.file(file, width: 100, height: 100);
                                  }).toList(),
                                ),
                          ElevatedButton(
                            onPressed: _pickExtraImages,
                            child: Text('Ek Resimler Seç'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    // Kaydet ve İptal butonları
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _handleAddProduct,
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
