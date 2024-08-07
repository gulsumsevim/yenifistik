import 'package:fistikpazar/services/basket_services.dart';
import 'package:flutter/material.dart';
import 'package:fistikpazar/models/favorite_model.dart';
import 'package:fistikpazar/services/favorite_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late FavoritesService _favoritesService;
  late Future<List<Favorites>> _favoritesFuture;
  late BasketService _basketService;
  Set<int> likedProducts = Set<int>();

  @override
  void initState() {
    super.initState();
    _favoritesService = FavoritesService();
    _favoritesFuture = _favoritesService.getAllFavorites();
    _basketService = BasketService();
    _loadLikedProducts();
  }

  Future<void> _loadLikedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final likedProductIds = prefs.getStringList('likedProducts') ?? [];
    setState(() {
      likedProducts = likedProductIds.map((id) => int.parse(id)).toSet();
    });
  }

  Future<void> _removeFavorite(int productId) async {
    try {
      await _favoritesService.removeFavorite(productId);
      setState(() {
        _favoritesFuture = _favoritesService.getAllFavorites();
        likedProducts.remove(productId);
        _saveLikedProducts();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Favori ürünü silerken bir hata oluştu: $e')),
      );
    }
  }

  Future<void> _saveLikedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final likedProductIds = likedProducts.map((id) => id.toString()).toList();
    prefs.setStringList('likedProducts', likedProductIds);
  }

  Future<void> _addToBasket(int productId) async {
    try {
      await _basketService.addToBasket(productId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün sepete eklendi.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürünü sepete eklerken bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 240, 219),
        elevation: 0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Favori Ürünlerim',
            style: TextStyle(
              fontFamily: 'Yellowtail-Regular.ttf', // Kullanmak istediğiniz font ailesi
              fontSize: 25.0, // Yazı boyutu
              fontWeight: FontWeight.bold, // Yazı kalınlığı
              color: Colors.black, // Yazı rengi
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<List<Favorites>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Favori ürün bulunamadı.'));
          } else {
            final favorites = snapshot.data!;
            return ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                return Card(
                  color: const Color.fromARGB(255, 255, 240, 219),
                  margin: EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 2.0,
                        child: Image.network(
                          favorite.picture,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              favorite.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text('Kategori: ${favorite.category}'),
                            Text('Fiyat: ${favorite.price} TL'),
                            Text('Hasat: ${favorite.harvest}'),
                            Text('Stok: ${favorite.stock}'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('ID: ${favorite.productId}'), // ID'yi göstermek için ekledim, gerekirse çıkarılabilir
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.favorite, color: Colors.red),
                                      onPressed: () {
                                        _removeFavorite(favorite.productId);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.shopping_cart, color: Colors.green),
                                      onPressed: () {
                                        _addToBasket(favorite.productId);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
