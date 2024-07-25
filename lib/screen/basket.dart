import 'package:flutter/material.dart';
import 'package:fistikpazar/screen/orderConfirmationPage.dart';
import 'package:fistikpazar/models/basket_model.dart';
import 'package:fistikpazar/services/basket_services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BasketsPage extends StatefulWidget {
  @override
  _BasketsPageState createState() => _BasketsPageState();
}

class _BasketsPageState extends State<BasketsPage> {
  final BasketService _basketService = BasketService();
  late Future<List<Baskets>> _basketsFuture;
  List<Baskets> _baskets = [];
  List<int> _selectedBasketIds = [];
  bool _showCheckboxes = false;

  TextEditingController _orderNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _basketsFuture = _fetchBaskets();
  }

  Future<List<Baskets>> _fetchBaskets() async {
    return await _basketService.getAllBaskets();
  }

  Future<void> _deleteBasket(int basketId) async {
    try {
      await _basketService.removeFromBasket(basketId);
      setState(() {
        _basketsFuture = _fetchBaskets();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün sepetten çıkarılırken bir hata oluştu: $e')),
      );
    }
  }

  Future<void> _updateQuantity(int basketId, int newQuantity) async {
    try {
      await _basketService.updateBasketQuantity(basketId, newQuantity);
      setState(() {
        _basketsFuture = _fetchBaskets();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün miktarı güncellenirken bir hata oluştu: $e')),
      );
    }
  }

  void _incrementQuantity(int basketId, int currentQuantity) {
    _updateQuantity(basketId, currentQuantity + 1);
  }

  void _decrementQuantity(int basketId, int currentQuantity) {
    if (currentQuantity > 1) {
      _updateQuantity(basketId, currentQuantity - 1);
    }
  }

  double _calculateTotalPrice(List<Baskets> baskets) {
    return baskets.fold(0.0, (sum, item) => sum + (item.price * item.numberOfProduct));
  }

  int _calculateTotalItems(List<Baskets> baskets) {
    return baskets.fold(0, (sum, item) => sum + item.numberOfProduct);
  }

  void _onLongPress(Baskets basket) {
    setState(() {
      _showCheckboxes = true;
      _selectedBasketIds.add(basket.basketId);
    });
  }

  void _onTap(Baskets basket) {
    if (_showCheckboxes) {
      setState(() {
        if (_selectedBasketIds.contains(basket.basketId)) {
          _selectedBasketIds.remove(basket.basketId);
        } else {
          _selectedBasketIds.add(basket.basketId);
        }
      });
    }
  }

  Future<void> _deleteSelectedBaskets() async {
    for (int basketId in _selectedBasketIds) {
      await _deleteBasket(basketId);
    }
    setState(() {
      _selectedBasketIds.clear();
      _showCheckboxes = false;
    });
  }

  void _cancelSelection() {
    setState(() {
      _showCheckboxes = false;
      _selectedBasketIds.clear();
    });
  }

  Future<void> _addProductsToTempBasket() async {
    final String? token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Token alınamadı')));
      return;
    }

    final response = await http.post(
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/Customer/AddProductToTempBasket'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'basketIds': _baskets.map((basket) => basket.basketId).toList(),
      }),
    );

    print('HTTP yanıtı: ${response.body}');

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationPage(
            totalPrice: _calculateTotalPrice(_baskets),
            totalItems: _calculateTotalItems(_baskets),
            orderNote: _orderNoteController.text,
          ),
        ),
      );
    } else {
      final responseData = jsonDecode(response.body);
      final message = responseData['message'] ?? 'Ürünler sepete eklenemedi';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
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
            'Sepetim',
            style: TextStyle(
              fontFamily: 'Yellowtail-Regular.ttf',
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          if (_showCheckboxes)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteSelectedBaskets,
            ),
          if (_showCheckboxes)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: _cancelSelection,
            ),
        ],
      ),
      body: FutureBuilder<List<Baskets>>(
        future: _basketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Sepetinizde ürün bulunmamaktadır.'));
          } else {
            _baskets = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _baskets.length,
                    itemBuilder: (context, index) {
                      final product = _baskets[index];
                      return GestureDetector(
                        onLongPress: () => _onLongPress(product),
                        child: Card(
                          color: const Color.fromARGB(255, 255, 240, 219),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                product.image.isNotEmpty
                                    ? Image.network(
                                        product.image,
                                        fit: BoxFit.cover,
                                        width: 60,
                                        height: 60,
                                      )
                                    : Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey,
                                        child: Center(child: Icon(Icons.image)),
                                      ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Text('Miktar: ${product.numberOfProduct}'),
                                    Text('${product.price.toStringAsFixed(2)} ₺'),
                                  ],
                                ),
                                Spacer(),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () => _decrementQuantity(product.basketId, product.numberOfProduct),
                                    ),
                                    Text('${product.numberOfProduct}'),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () => _incrementQuantity(product.basketId, product.numberOfProduct),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteBasket(product.basketId),
                                ),
                                if (_showCheckboxes)
                                  Checkbox(
                                    value: _selectedBasketIds.contains(product.basketId),
                                    onChanged: (bool? selected) {
                                      _onTap(product);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sipariş Notu',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _orderNoteController,
                        maxLines: 3, // Yüksekliği azaltmak için maxLines'u 3 yapıyoruz.
                        decoration: InputDecoration(
                          hintText: 'Not giriniz...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.brown),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 240, 219),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Toplam Ürün:'),
                          Text('${_calculateTotalItems(_baskets)}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Toplam Fiyat:'),
                          Text('${_calculateTotalPrice(_baskets).toStringAsFixed(2)} ₺'),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _addProductsToTempBasket,
                        child: Text('Siparişi Onayla'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 218, 214, 211),
                          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                          textStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
