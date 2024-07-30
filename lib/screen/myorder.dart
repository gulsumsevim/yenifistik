import 'package:fistikpazar/models/myorder_model.dart';
import 'package:fistikpazar/screen/login_page.dart';
import 'package:fistikpazar/screen/myorderdetail.dart';
import 'package:fistikpazar/services/myorder_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MyOrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyOrderScreen(),
    );
  }
}

class MyOrderScreen extends StatefulWidget {
  @override
  _PanelScreenState createState() => _PanelScreenState();
}

class _PanelScreenState extends State<MyOrderScreen> {
  bool _isLoading = true;
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _fetchOrders();
  }

  Future<void> _checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    int? roleId = prefs.getInt('roleId');

    if (roleId == null || roleId != 2) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _fetchOrders() async {
    try {
      final orderService = OrderService();
      final fetchedOrders = await orderService.getOrders();
      setState(() {
        orders = fetchedOrders;
        _isLoading = false;
      });
    } catch (e) {
      print('Hata: $e');
      setState(() {
        _isLoading = false;
      });
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailPage(order: order),
                        ),
                      );
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
                              DateFormat('dd MMMM yyyy HH:mm').format(order.createdDate),
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            _buildOrderStatus(order.orderStatus),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
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
      statusColor = Colors.brown;
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
      statusText = 'Sipariş alındı';
      statusColor = Colors.brown;
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
