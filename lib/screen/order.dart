import 'package:fistikpazar/models/order_model.dart';
import 'package:fistikpazar/screen/orderdetail.dart';
import 'package:fistikpazar/services/order_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderListScreen extends StatefulWidget {
  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late Future<Orders> futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders = OrderService().getAllOrders();
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
            'Siparişlerim',
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
      body: FutureBuilder<Orders>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.orderIds!.isEmpty) {
            return Center(child: Text('Hiç sipariş bulunamadı'));
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: snapshot.data!.orderIds!.length,
              itemBuilder: (context, index) {
                final order = snapshot.data!.orderIds![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(orderId: order.orderId!),
                        ),
                      );
                      if (result == true) {
                        setState(() {
                          futureOrders = OrderService().getAllOrders();
                        });
                      }
                    },
                    child: Card(
                      color: index % 2 == 0 ? Color.fromARGB(255, 255, 240, 219) : Color.fromARGB(255, 240, 255, 240),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
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
                            Text(
                              DateFormat('dd MMMM yyyy HH:mm').format(DateTime.parse(order.createdDate!)),
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            _buildOrderStatus(order.orderStatus!),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildOrderStatus(int status) {
    String statusText;
    Color statusColor;

    switch (status) {
      case 1:
        statusText = 'Sipariş alındı';
        statusColor = Colors.green;
        break;
      case 2:
        statusText = 'Sipariş hazırlanıyor';
        statusColor = Colors.orange;
        break;
      case 3:
        statusText = 'Sipariş kargoya verildi';
        statusColor = Colors.blue;
        break;
      case 4:
        statusText = 'Sipariş teslim edildi';
        statusColor = Colors.green;
        break;
      case 5:
        statusText = 'Sipariş iptal edildi';
        statusColor = Colors.red;
        break;
      default:
        statusText = 'Sipariş iptal edildi';
        statusColor = Colors.red;
    }

    return Row(
      children: [
        Icon(Icons.circle, color: statusColor, size: 16),
        SizedBox(width: 8),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 16,
            color: statusColor,
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: OrderListScreen(),
  ));
}
