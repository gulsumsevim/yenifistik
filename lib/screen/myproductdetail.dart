import 'dart:io';
import 'package:fistikpazar/models/MyProductDetail.dart';
import 'package:fistikpazar/screen/myproduct.dart';
import 'package:fistikpazar/services/myproduct_services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
              child: Form(
                key: _formKey,
                child: ListView(
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
            );
          }
        },
      ),
    );
  }
}
