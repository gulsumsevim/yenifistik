import 'package:fistikpazar/models/myorder_model.dart';
import 'package:flutter/material.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;

  OrderDetailPage({required this.order});

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
            buildOrderStatus(order.orderStatus),
            SizedBox(height: 16),
            buildProductList(order.orderProducts),
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

  Widget buildOrderStatus(int status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildStatusStep(Icons.receipt, 'Sipariş alındı', status >= 1, 'Sipariş kontrol edildi', Colors.green),
        buildStatusStep(Icons.kitchen, 'Sipariş hazırlanıyor', status >= 2, 'Sipariş kontrol edildi', Colors.orange),
        buildStatusStep(Icons.local_shipping, 'Sipariş kargoya verildi', status >= 3, 'Ürünler henüz hazırlanmadı', Colors.grey),
        buildStatusStep(Icons.check_circle, 'Sipariş teslim edildi', status >= 4, 'Ürünler henüz hazırlanmadı', Colors.grey),
        
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
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                // Ürün hazırlandı işlemi
              },
              child: Text('Ürün hazırlandı'),
              style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 255, 240, 219),),
            ),
          ],
        ),
      ),
    );
  }
}



