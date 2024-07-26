import 'dart:convert';
import 'dart:io';
import 'package:fistikpazar/models/MyProductDetail.dart';
import 'package:fistikpazar/screen/myproduct.dart';
import 'package:fistikpazar/services/login_services.dart';
import 'package:fistikpazar/services/myproduct_services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class MyProductDetailPage extends StatefulWidget {
  final int productId;

  MyProductDetailPage({required this.productId});

  @override
  _MyProductDetailPageState createState() => _MyProductDetailPageState();
}

class _MyProductDetailPageState extends State<MyProductDetailPage> {
  late Future<ProductUpdate> productDetail;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryIdController;
  late TextEditingController _priceController;
  late TextEditingController _harvestController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;
  late TextEditingController _fieldIdController;
  late TextEditingController _productSizeIdController;
  File? _selectedImage;
  String? _existingImageUrl;

  TextEditingController _campaignNameController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _rateController = TextEditingController();

  List<Map<String, dynamic>> campaigns = [];

  @override
  void initState() {
    super.initState();
    productDetail = MyProductService.getProductDetail(widget.productId).then((product) {
      _nameController = TextEditingController(text: product.name);
      _categoryIdController = TextEditingController(text: product.categoryId.toString());
      _priceController = TextEditingController(text: product.price.toString());
      _harvestController = TextEditingController(text: product.harvest.toString());
      _stockController = TextEditingController(text: product.stock.toString());
      _descriptionController = TextEditingController(text: product.description);
      _fieldIdController = TextEditingController(text: product.fieldId.toString());
      _productSizeIdController = TextEditingController(text: product.productSizeId.toString());
      _existingImageUrl = product.image;
      return product;
    });
    fetchCampaigns();
  }

  Future<void> fetchCampaigns() async {
    final String? token = await ApiService.getToken(); // Token alınması

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token alınamadı')),
      );
      return;
    }

    final response = await http.get(
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/Farmer/GetCampaign'),
      headers: {
        'accept': 'text/plain',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      setState(() {
        campaigns = List<Map<String, dynamic>>.from(jsonResponse['campaigns'])
            .where((campaign) => campaign['productId'] == widget.productId)
            .toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kampanyalar alınırken bir hata oluştu: ${response.statusCode}')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedProduct = ProductUpdate(
          productId: widget.productId,
          name: _nameController.text,
          categoryId: int.parse(_categoryIdController.text),
          price: double.parse(_priceController.text),
          harvest: int.parse(_harvestController.text),
          stock: int.parse(_stockController.text),
          description: _descriptionController.text,
          fieldId: int.parse(_fieldIdController.text),
          productSizeId: int.parse(_productSizeIdController.text),
          image: _selectedImage == null ? _existingImageUrl! : "", // Update with appropriate image path if required
        );

        await MyProductService.updateProduct(updatedProduct);

        if (_selectedImage != null) {
          await MyProductService.uploadMainImageToProduct(widget.productId, _selectedImage!);
        }

        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ürün başarıyla güncellendi')),
        );

        Navigator.of(context).pop(); // Bu sayfayı kapat
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProductScreen(), // Ürünler sayfasına git
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ürün güncellenirken bir hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _addCampaign() async {
    final String? token = await ApiService.getToken(); // Token alınması

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token alınamadı')),
      );
      return;
    }

    if (_campaignNameController.text.isEmpty ||
        _startDateController.text.isEmpty ||
        _endDateController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/Farmer/AddCampaign'),
      headers: {
        'accept': 'text/plain',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "name": _campaignNameController.text,
        "startDate": _startDateController.text,
        "endDate": _endDateController.text,
        "productId": widget.productId,
        "quantity": int.parse(_amountController.text),
        "discountRate": int.parse(_rateController.text)
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kampanya başarıyla eklendi')),
      );
      Navigator.of(context).pop(); // Kampanya ekleme dialogunu kapat
      fetchCampaigns(); // Kampanyaları yeniden yükle
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kampanya eklenirken bir hata oluştu: ${response.statusCode}')),
      );
    }
  }

  Future<void> _deleteCampaign(int campaignId) async {
    final String? token = await ApiService.getToken(); // Token alınması

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token alınamadı')),
      );
      return;
    }

    final response = await http.put(
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/Farmer/DeleteCampaignAsync'),
      headers: {
        'accept': 'text/plain',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "campaignId": campaignId,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kampanya başarıyla silindi')),
      );
      fetchCampaigns(); // Kampanyaları yeniden yükle
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kampanya silinirken bir hata oluştu: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürün Detayları'),
      ),
      body: FutureBuilder<ProductUpdate>(
        future: productDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Ürün bulunamadı.'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _selectedImage == null
                                ? Image.network(
                                    _existingImageUrl ?? '',
                                    height: 200,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    _selectedImage!,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: Text('Resim Seç'),
                            ),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(labelText: 'Ürün Adı'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen ürün adını girin';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _categoryIdController,
                              decoration: InputDecoration(labelText: 'Kategori Id'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen kategori id\'yi girin';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
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
                            TextFormField(
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
                            TextFormField(
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
                            TextFormField(
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
                            TextFormField(
                              controller: _fieldIdController,
                              decoration: InputDecoration(labelText: 'Arazi Id'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen arazi id\'yi girin';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _productSizeIdController,
                              decoration: InputDecoration(labelText: 'Ürün Boyutu Id'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen ürün boyutu id\'yi girin';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _updateProduct,
                              child: Text('Güncelle'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _showAddCampaignDialog(context);
                      },
                      child: Text('Kampanya Ekle'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Kampanyalar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          campaigns.isEmpty
                              ? Text('Henüz Kampanya Eklenmemiş')
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: campaigns.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Kampanya Adı: ${campaigns[index]['name']}',
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  'Başlangıç Tarihi: ${DateFormat('dd.MM.yyyy').format(DateTime.parse(campaigns[index]['startDate']))}',
                                                ),
                                                Text(
                                                  'Bitiş Tarihi: ${DateFormat('dd.MM.yyyy').format(DateTime.parse(campaigns[index]['endDate']))}',
                                                ),
                                                Text('Miktarı: ${campaigns[index]['quantity']}'),
                                                Text('Oranı: ${campaigns[index]['discountRate']}'),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              _deleteCampaign(campaigns[index]['campaignId']);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void _showAddCampaignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Kampanya Ekle',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _campaignNameController,
                    decoration: InputDecoration(labelText: 'Kampanya Adı'),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _startDateController,
                          decoration: InputDecoration(labelText: 'Başlangıç Tarihi'),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              _startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _endDateController,
                          decoration: InputDecoration(labelText: 'Bitiş Tarihi'),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              _endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(labelText: 'Miktarı'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _rateController,
                    decoration: InputDecoration(labelText: 'Oranı'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_startDateController.text.isNotEmpty &&
                              _endDateController.text.isNotEmpty) {
                            DateTime startDate = DateTime.parse(_startDateController.text);
                            DateTime endDate = DateTime.parse(_endDateController.text);
                            if (startDate.isAfter(endDate)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Başlangıç tarihi bitiş tarihinden önce olamaz')),
                              );
                            } else {
                              _addCampaign();
                              Navigator.of(context).pop();
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lütfen tüm tarihleri girin')),
                            );
                          }
                        },
                        child: Text('Ekle'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('İptal'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
