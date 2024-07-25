import 'package:fistikpazar/screen/productdetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fistikpazar/models/product_model.dart';
import 'package:fistikpazar/screen/product_filters_dialog.dart';
import 'package:fistikpazar/screen/ui_util.dart';
import 'package:fistikpazar/services/products_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(ProductPage());
}

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Products> products = [];
  List<Products> filteredProducts = [];
  Set<int> likedProducts = Set<int>(); // Set to store liked product IDs

  @override
  void initState() {
    super.initState();
    _loadLikedProducts();
    ProductService.getAllProducts().then((retrievedProducts) {
      setState(() {
        products = retrievedProducts;
        filteredProducts = retrievedProducts;
      });
    });
  }

  Future<void> _loadLikedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final likedProductIds = prefs.getStringList('likedProducts') ?? [];
    setState(() {
      likedProducts = likedProductIds.map((id) => int.parse(id)).toSet();
    });
  }

  Future<void> _saveLikedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final likedProductIds = likedProducts.map((id) => id.toString()).toList();
    prefs.setStringList('likedProducts', likedProductIds);
  }

  void _addToBasket(BuildContext context, int productId) async {
    try {
      await ProductService.addProductToBasket(productId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün sepete eklendi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün sepete eklenirken bir hata oluştu: $e')),
      );
    }
  }

  void _toggleLikeProduct(BuildContext context, int productId) async {
    setState(() {
      if (likedProducts.contains(productId)) {
        likedProducts.remove(productId);
      } else {
        likedProducts.add(productId);
      }
    });
    await _saveLikedProducts();

    try {
      if (likedProducts.contains(productId)) {
        await ProductService.addLikeToProduct(productId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ürün beğenildi')),
        );
      } else {
        await ProductService.removeLikeFromProduct(productId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ürün beğenmekten vazgeçildi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İşlem sırasında bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 255, 240, 219),
          title: Text(
            'Ürünler',
            style: TextStyle(
              fontFamily: 'Yellowtail-Regular.ttf',
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
              icon: SvgPicture.asset(
                'icons/filter.svg',
                width: 24,
                height: 24,
                color: Colors.black,
              ),
              onPressed: () {
                UiUtil.openBottomSheet(
                  context: context,
                  widget: ProductFiltersDialog(
                    onFilteredTap: (categories, productSizes, price) {
                      filteredProducts = products.where((product) {
                        if (categories == null || categories.isEmpty) return true;
                        if (categories.contains("Tümü")) return true;
                        return categories.contains(product.category);
                      }).where((product) {
                        if (price == null) return true;
                        var min = price.start;
                        var max = price.end;
                        return (product.price ?? 0) >= min && (product.price ?? 0) <= max;
                      }).toList();
                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/fıstık.png'), // Banner resmini ekleyin
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (BuildContext context, int index) {
                  return ProductCard(
                    product: filteredProducts[index],
                    isLiked: likedProducts.contains(filteredProducts[index].productId),
                    onAddToBasket: (productId) {
                      _addToBasket(context, productId);
                    },
                    onLikeProduct: (productId) {
                      _toggleLikeProduct(context, productId);
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(productId: filteredProducts[index].productId!),
                        ),
                      ).then((_) {
                        setState(() {}); // Refresh the state when returning from the detail page
                      });
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Products product;
  final bool isLiked;
  final Function(int) onAddToBasket;
  final Function(int) onLikeProduct;
  final VoidCallback onTap;

  const ProductCard({
    Key? key,
    required this.product,
    required this.isLiked,
    required this.onAddToBasket,
    required this.onLikeProduct,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Color.fromARGB(255, 255, 240, 219),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                height: 150,
                child: product.image != null
                    ? Image.network(
                        product.image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: Colors.grey,
                        child: Center(child: Icon(Icons.image)),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${product.category ?? ''} - ${(product.price ?? 0).toStringAsFixed(2)} ₺',
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.add_shopping_cart),
                  onPressed: () {
                    if (product.productId != null) {
                      onAddToBasket(product.productId!);
                    } else {
                      print('Ürün ID bilgisi eksik.');
                    }
                  },
                ),
                IconButton(
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                  color: isLiked ? Colors.red : null,
                  onPressed: () {
                    if (product.productId != null) {
                      onLikeProduct(product.productId!);
                    } else {
                      print('Ürün ID bilgisi eksik.');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
