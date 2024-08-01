import 'dart:convert';
import 'package:fistikpazar/models/myorder_model.dart';
import 'package:fistikpazar/services/login_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderDetailPage extends StatefulWidget {
  final Order order;

  OrderDetailPage({required this.order});

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Order order;

  @override
  void initState() {
    super.initState();
    order = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 240, 219),
        title: Text('Sipariş Detayları'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildOrderSummary(order),
            SizedBox(height: 16),
            buildOrderStatus(order.orderStatus, context),
            SizedBox(height: 16),
            buildProductList(order.orderProducts, context),
          ],
        ),
      ),
    );
  }

  Widget buildOrderSummary(Order order) {
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
            buildDetailRow('Kullanıcı adı:', order.fullName),
            buildDetailRow('E-posta:', order.email),
            buildDetailRow('Teslimat Adresi:', '${order.province} / ${order.township}\n${order.fullAddress}'),
            buildDetailRow('Fatura Adresi:', order.invoice),
            buildDetailRow('Sipariş Notu:', order.orderNote),
            SizedBox(height: 8),
            Text(
              'Toplam Tutar: ${order.totalPrice.toStringAsFixed(2)}₺',
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

  Widget buildOrderStatus(int orderStatus, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildStatusStep(Icons.receipt, 'Sipariş alındı', orderStatus >= 1, 'Sipariş kontrol edildi', Colors.green, 1, context),
        buildStatusStep(Icons.kitchen, 'Sipariş hazırlanıyor', orderStatus >= 2, 'Sipariş hazırlanıyor', Colors.orange, 2, context),
        buildStatusStep(Icons.local_shipping, 'Sipariş kargoya verildi', orderStatus >= 3, 'Sipariş kargoya verildi', Color.fromARGB(255, 209, 191, 29), 3, context),
        buildStatusStep(Icons.check_circle, 'Sipariş teslim edildi', orderStatus >= 4, 'Sipariş teslim edildi', Colors.blue, 4, context),
        buildStatusStep(Icons.cancel, 'Sipariş iptal edildi', orderStatus >= 5, 'Sipariş iptal edildi', Colors.red, 5, context),
      ],
    );
  }

  Widget buildStatusStep(IconData icon, String title, bool isActive, String description, Color color, int status, BuildContext context) {
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
        if (!isActive && status == order.orderStatus + 1 && order.orderStatus != 5)
          ElevatedButton(
            onPressed: () async {
              await updateOrderStatus(order.orderId, status, context);
            },
            child: Text('Onayla'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
            ),
          ),
      ],
    );
  }

  Widget buildProductList(List<OrderProduct> products, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: products.map((product) => buildProductCard(product, context)).toList(),
    );
  }

  Widget buildProductCard(OrderProduct product, BuildContext context) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 4,
    color: Color.fromARGB(255, 255, 240, 219),
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          product.pictureUrl.isNotEmpty
              ? Image.network(product.pictureUrl, fit: BoxFit.cover, width: 60, height: 60)
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
                Text(product.productName, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('${product.amount} x ${product.price}₺', style: TextStyle(color: Colors.grey[600])),
                Text('Toplam: ${(product.amount * product.price).toStringAsFixed(2)}₺', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Ürünü hazırla işlemini burada yapabilirsiniz.
              prepareProduct(product);
            },
            child: Text('Ürünü Hazırla'),
          ),
        ],
      ),
    ),
  );
}

void prepareProduct(OrderProduct product) {
  // Ürünü hazırla işlemleri burada yapılabilir.
  print('Ürünü hazırlama işlemi başlatıldı: ${product.productName}');
}

  Future<void> updateOrderStatus(int orderId, int orderStatus, BuildContext context) async {
    final String? token = await ApiService.getToken(); // Token alınması

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token alınamadı')),
      );
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('https://api.fistikpazar.com/api/Farmer/UpdateOrderStatus'),
        headers: {
          'accept': 'text/plain',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "orderId": orderId,
          "orderStatus": orderStatus
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sipariş durumu güncellendi')),
        );

        // Durum güncellendikten sonra bir sonraki duruma geçiş
        setState(() {
          order = order.copyWith(orderStatus: orderStatus);
        });

        // Aşağı kaydırma
        Future.delayed(Duration(milliseconds: 500), () {
          Scrollable.ensureVisible(context, duration: Duration(seconds: 1));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sipariş durumu güncellenirken bir hata oluştu: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }
}