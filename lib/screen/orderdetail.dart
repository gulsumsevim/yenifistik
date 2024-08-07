import 'package:fistikpazar/models/orderdetail_model.dart';
import 'package:fistikpazar/screen/productdetails.dart';
import 'package:fistikpazar/services/order_services.dart';
import 'package:fistikpazar/services/orderdetail_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';



class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  OrderDetailScreen({required this.orderId});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<OrderDetail?> futureOrderDetail;
  int quantity = 2;

  @override
  void initState() {
    super.initState();
    futureOrderDetail = OrderDetailService().getOrderDetail(widget.orderId);
  }

  Future<void> cancelOrder() async {
    try {
      final String? token = await _getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Token alınamadı')));
        return;
      }

      final response = await http.put(
        Uri.parse('https://api.fistikpazar.com/api/Customer/DeleteOrderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "orderId": widget.orderId, // Gönderilecek orderId
        }),
      );

      print('HTTP yanıt kodu: ${response.statusCode}');
      print('HTTP yanıtı: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == '200') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sipariş iptal edildi.')));
          Navigator.pop(context, true); // Sipariş iptal edildikten sonra geri dön ve true değerini döndür
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData['message'] ?? 'Sipariş iptal edilemedi')));
        }
      } else {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'Sipariş iptal edilemedi';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sipariş iptal edilemedi: $e')));
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
            'Sipariş Detayı',
            style: TextStyle(
              fontFamily: 'Yellowtail-Regular.ttf',
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<OrderDetail?>(
        future: futureOrderDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Sipariş detayları bulunamadı veya iptal edildi.'));
          } else {
            OrderDetail orderDetail = snapshot.data!;
            return ListView(
              padding: EdgeInsets.all(16.0),
              children: <Widget>[
                buildOrderSummary(orderDetail),
                SizedBox(height: 16),
                buildOrderStatus(orderDetail.orderStatus!),
                SizedBox(height: 16),
                buildProductList(orderDetail.orderProducts!),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: cancelOrder,
                  child: Text('Siparişi İptal Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildOrderSummary(OrderDetail order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      color: Color.fromARGB(255, 255, 240, 219),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sipariş No: ${order.orderId}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            buildDetailRow('Kullanıcı adı:', order.fullName ?? ''),
            buildDetailRow('E-posta:', order.email ?? ''),
            buildDetailRow('Teslimat Adresi:', '${order.province ?? ''} / ${order.township ?? ''}\n${order.fullAddress ?? ''}'),
            buildDetailRow('Fatura Adresi:', order.invoice ?? ''),
            buildDetailRow('Sipariş Notu:', order.orderNote ?? ''),
            SizedBox(height: 8),
            Text(
              'Toplam Tutar: ${order.totalPrice?.toStringAsFixed(2)}₺',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget buildOrderStatus(int status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildStatusStep(Icons.receipt, 'Sipariş alındı', status >= 1, 'Sipariş kontrol edildi', Colors.green),
        buildStatusStep(Icons.kitchen, 'Sipariş hazırlanıyor', status >= 2, 'Sipariş hazırlanıyor', Colors.orange),
        buildStatusStep(Icons.local_shipping, 'Sipariş kargoya verildi', status >= 3, 'Ürünler kargoya verildi', Colors.grey),
        buildStatusStep(Icons.check_circle, 'Sipariş teslim edildi', status >= 4, 'Ürünler teslim edildi', Colors.grey),
      ],
    );
  }

  Widget buildStatusStep(IconData icon, String title, bool isActive, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 1,
              height: 24,
              color: isActive ? color : Colors.grey,
            ),
            Icon(icon, color: isActive ? color : Colors.grey),
            Container(
              width: 1,
              height: 24,
              color: isActive ? color : Colors.grey,
            ),
          ],
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isActive ? color : Colors.grey,
                ),
              ),
              if (isActive)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildProductList(List<OrderProduct> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: products.map((product) => buildProductCard(product)).toList(),
    );
  }

  Widget buildProductCard(OrderProduct product) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      color: Color.fromARGB(255, 255, 240, 219),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            product.pictureUrl?.isNotEmpty == true
                ? Image.network(product.pictureUrl!, fit: BoxFit.cover, width: 60, height: 60)
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey,
                    child: Center(child: Icon(Icons.image)),
                  ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.productName ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('${product.amount} x ${product.price?.toStringAsFixed(2)}₺', style: TextStyle(color: Colors.grey[600])),
                  Text('Toplam: ${(product.amount! * product.price!).toStringAsFixed(2)}₺', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductDetailPage(productId: product.productId!)),
                );
              },
              child: Text('Ürünü Gör'),
            ),
          ],
        ),
      ),
    );
  }
}
