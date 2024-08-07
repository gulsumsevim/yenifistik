import 'package:fistikpazar/models/begeni_model.dart';
import 'package:fistikpazar/models/comment_model.dart';
import 'package:fistikpazar/services/begeni_services.dart';
import 'package:fistikpazar/services/comment_services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fistikpazar/screen/login_page.dart';
import 'package:fistikpazar/models/myorder_model.dart';
import 'package:fistikpazar/services/myorder_services.dart';
import 'package:intl/intl.dart';

class PanelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PanelimScreen(),
    );
  }
}

class PanelimScreen extends StatefulWidget {
  @override
  _PanelScreenState createState() => _PanelScreenState();
}

class _PanelScreenState extends State<PanelimScreen> {
  String profileName = 'Yükleniyor...';
  bool _isLoading = false;
  late Future<List<DailyLike>> _dailyLikesFuture;
  late Future<List<Comment>> _commentsFuture;
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _dailyLikesFuture = DailyLikeService.getDailyLikes();
    _commentsFuture = CommentService.getAllComments();
    _ordersFuture = OrderService().getOrders();
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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
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
            'Panelim',
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
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSalesCard('Günlük Satış', '524₺'),
                        _buildSalesCard('Aylık Satış', '8640₺'),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Siparişler',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        FutureBuilder<List<Order>>(
                          future: _ordersFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              print('Order Error: ${snapshot.error}');
                              return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              print('Order Data: Boş');
                              return Center(child: Text('Veri bulunamadı.'));
                            } else {
                              final orders = snapshot.data!;
                              print('Order Data: ${orders.length} adet sipariş alındı.');
                              return Column(
                                children: orders.map((order) {
                                  return Card(
                                    color: Color.fromARGB(255, 255, 240, 219),
                                    child: ListTile(
                                      leading: Image.network(
                                        order.orderProducts.isNotEmpty
                                            ? order.orderProducts.first.pictureUrl
                                            : 'https://via.placeholder.com/150',
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                      ),
                                      title: Text(order.fullName),
                                      subtitle: Text(
                                        '${order.orderProducts.length} x ${order.totalPrice.toStringAsFixed(2)}₺',
                                      ),
                                      trailing: Text('${order.totalPrice.toStringAsFixed(2)}₺'),
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Card(
                          color: Color.fromARGB(255, 255, 240, 219),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Haftalık Beğeni Sayısı',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 150,
                                  child: FutureBuilder<List<DailyLike>>(
                                    future: _dailyLikesFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        print('DailyLikes Error: ${snapshot.error}');
                                        return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
                                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                        print('DailyLikes Data: Boş');
                                        return Center(child: Text('Veri bulunamadı.'));
                                      } else {
                                        final dailyLikes = snapshot.data!;
                                        final List<BarChartGroupData> barGroups = [];

                                        final daysOfWeek = ['pazartesi', 'salı', 'çarşamba', 'perşembe', 'cuma', 'cumartesi', 'pazar'];
                                        final Map<String, int> likesPerDay = { for (var day in daysOfWeek) day: 0 };

                                        for (var like in dailyLikes) {
                                          final date = DateTime.parse(like.date.toIso8601String());
                                          final day = DateFormat('EEEE', 'tr_TR').format(date).toLowerCase();
                                          if (likesPerDay.containsKey(day)) {
                                            likesPerDay[day] = like.likeCount;
                                            print('Gün: $day, Beğeni: ${likesPerDay[day]}');
                                          }
                                        }

                                        for (var i = 0; i < daysOfWeek.length; i++) {
                                          barGroups.add(
                                            BarChartGroupData(
                                              x: i,
                                              barRods: [
                                                BarChartRodData(
                                                  toY: likesPerDay[daysOfWeek[i]]!.toDouble(),
                                                  color: Colors.blue,
                                                  width: 20,
                                                  borderRadius: BorderRadius.circular(0),
                                                  backDrawRodData: BackgroundBarChartRodData(
                                                    show: true,
                                                    toY: 20,
                                                    color: Colors.blue.withOpacity(0.1),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }

                                        print('DailyLikes Data: ${dailyLikes.length} adet beğeni alındı.');
                                        return BarChart(
                                          BarChartData(
                                            alignment: BarChartAlignment.spaceAround,
                                            barGroups: barGroups,
                                            titlesData: FlTitlesData(
                                              leftTitles: AxisTitles(
                                                axisNameWidget: Padding(
                                                  padding: const EdgeInsets.only(left: 8.0),
                                                  child: Text(
                                                    'Haftalık Beğeni Sayısı',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                sideTitles: SideTitles(showTitles: false),
                                              ),
                                              rightTitles: AxisTitles(
                                                sideTitles: SideTitles(showTitles: false),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget: (double value, TitleMeta meta) {
                                                    final day = daysOfWeek[value.toInt()];
                                                    return Padding(
                                                      padding: const EdgeInsets.only(top: 8.0),
                                                      child: Text(
                                                        day,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.black,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            borderData: FlBorderData(show: false),
                                            gridData: FlGridData(show: false),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Danışman Notları',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        FutureBuilder<List<Comment>>(
                          future: _commentsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              print('Comments Error: ${snapshot.error}');
                              return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              print('Comments Data: Boş');
                              return Center(child: Text('Veri bulunamadı.'));
                            } else {
                              final comments = snapshot.data!;
                              print('Comments Data: ${comments.length} adet yorum alındı.');
                              return Column(
                                children: comments.map((comment) {
                                  return Card(
                                    color: Color.fromARGB(255, 255, 240, 219),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment.advisorName,
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            comment.advisorComment,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSalesCard(String title, String amount) {
    return Card(
      color: Color.fromARGB(255, 255, 240, 219),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: 150,
        height: 150,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
