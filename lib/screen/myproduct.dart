import 'package:flutter/material.dart';
import 'package:fistikpazar/screen/addproduct.dart';
import 'package:fistikpazar/screen/myproductdetail.dart';
import 'package:fistikpazar/models/myproduct_model.dart';
import 'package:fistikpazar/services/myproduct_services.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<List<MyProduct>> _productListFuture;

  @override
  void initState() {
    super.initState();
    _productListFuture = MyProductService.getMyProducts();
  }

  void _deleteProduct(int productId) async {
    try {
      await MyProductService.deleteProduct(productId);
      setState(() {
        _productListFuture = MyProductService.getMyProducts();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün başarıyla silindi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün silinirken bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 240, 219),
        title: Text('Ürünlerim'),
      ),
      body: FutureBuilder<List<MyProduct>>(
        future: _productListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Ürün bulunamadı.'));
          } else {
            final productList = snapshot.data!;
            return ListView.builder(
              itemCount: productList.length,
              itemBuilder: (context, index) {
                final product = productList[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    color: _getColor(index),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(product.image),
                      ),
                      title: Text(
                        product.name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kategori: ${product.category}'),
                          SizedBox(height: 5),
                          Text(
                            product.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5),
                          Text('Fiyat: ${product.price.toStringAsFixed(2)} ₺'),
                          Text('Hasat: ${product.harvest}'),
                          Text('Stok: ${product.stock}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProduct(product.productId),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyProductDetailPage(productId: product.productId),
                                ),
                              ).then((value) {
                                if (value == true) {
                                  setState(() {
                                    _productListFuture = MyProductService.getMyProducts();
                                  });
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductAddPage()),
          ).then((value) {
            if (value == true) {
              setState(() {
                _productListFuture = MyProductService.getMyProducts();
              });
            }
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getColor(int index) {
    final colors = [
      Colors.amber[100]!,
      Colors.green[100]!,
      Colors.blue[100]!,
    ];
    return colors[index % colors.length];
  }
}
