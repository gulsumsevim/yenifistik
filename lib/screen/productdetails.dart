import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fistikpazar/models/productdetail_model.dart';
import 'package:fistikpazar/services/products_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  ProductDetailPage({required this.productId});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final TextEditingController commentController = TextEditingController();
  double rating = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 240, 219),
        title: Text('Ürün Detayları'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
        
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () async {
              try {
                await ProductService.addProductToBasket(widget.productId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ürün sepete eklendi!')),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hata: $error')),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Details>(
        future: ProductService.getProductById(widget.productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Ürün bulunamadı.'));
          } else {
            final product = snapshot.data!;
            List<String> images = [if (product.image != null) product.image!] + (product.additionalImages?.map((img) => img.url!).toList() ?? []);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: images.isNotEmpty
                          ? CarouselSlider(
                              options: CarouselOptions(height: 200.0, enableInfiniteScroll: false, enlargeCenterPage: true),
                              items: images.map((imageUrl) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Image.network(imageUrl, fit: BoxFit.cover);
                                  },
                                );
                              }).toList(),
                            )
                          : Image.network(
                              'https://via.placeholder.com/150',
                              height: 200,
                            ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      product.name ?? 'Ürün Adı',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${product.price?.toStringAsFixed(2) ?? '0.00'} ₺/kg',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    SizedBox(height: 16),
                    Text(
                      product.description ?? 'Açıklama yok.',
                      style: TextStyle(fontSize: 16),
                    ),
                    Divider(),
                    _buildSectionTitle('Genel Bilgiler'),
                    _buildDetailBox('Kategori', product.category ?? 'Belirtilmemiş'),
                    
                    _buildDetailBox('Hasat', product.harvest?.toString() ?? '0'),
                    _buildDetailBox('Stok', product.stock?.toString() ?? '0'),
                    Divider(),
                    if (product.comments != null && product.comments!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Yorumlar'),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: product.comments!.length,
                              itemBuilder: (context, index) {
                                final comment = product.comments![index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: index % 2 == 0 ? Colors.grey[200] : Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Müşteri: ${comment.customerName ?? 'Bilinmiyor'}',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      
                                      Text(
                                        'Yorum: ${comment.commentt ?? 'Yorum yok'}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 16),
                    _buildCommentForm(context, commentController, widget.productId),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailBox(String title, String detail) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      color: Color.fromARGB(255, 255, 240, 219),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              detail,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentForm(BuildContext context, TextEditingController commentController, int productId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Yorum Ekle'),
        TextField(
          controller: commentController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Yorumunuzu yazın...',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final comment = commentController.text;
                final point = rating;

                if (comment.isEmpty || point <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lütfen geçerli bir yorum ve puan giriniz.')),
                  );
                  return;
                }

                try {
                  await ProductService.addCommentToProduct(productId, comment, point.toInt());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Yorum eklendi!')),
                  );
                  commentController.clear();
                  this.rating = 0;
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $error')),
                  );
                }
              },
              child: Text('Yorum Ekle'),
            ),
          ],
        ),
      ],
    );
  }
}
