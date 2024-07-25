import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fistikpazar/screen/basket.dart';
import 'package:fistikpazar/screen/favorite.dart';
import 'package:fistikpazar/screen/producerpanel.dart';
import 'package:fistikpazar/screen/product.dart';
import 'package:fistikpazar/screen/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(CustomerHomePage());
}

class CustomerHomePage extends StatelessWidget {
  CustomerHomePage({super.key});
  final _pageController = PageController();

  void dispose() {
    _pageController.dispose();
  }

  Future<bool> _isFarmer() async {
    final prefs = await SharedPreferences.getInstance();
    int? roleId = prefs.getInt('roleId');
    return roleId == 2;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isFarmer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Bir hata oluştu.'));
        } else {
          bool isFarmer = snapshot.data ?? false;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: PageView(
                controller: _pageController,
                children: <Widget>[
                  ProductPage(),
                  BasketsPage(),
                  FavoritesScreen(),
                  ProfilePage(),
                  if (isFarmer) PanelPage(),
                ],
              ),
              bottomNavigationBar: CurvedNavigationBar(
                backgroundColor: Colors.orange,
                buttonBackgroundColor: Colors.white,
                color: const Color.fromARGB(255, 255, 240, 219),
                height: 72,
                items: <Widget>[
                  Icon(
                    Icons.home,
                    size: 30,
                    color: Colors.red,
                  ),
                  Icon(
                    Icons.add_shopping_cart,
                    size: 30,
                    color: Colors.deepPurpleAccent,
                  ),
                  Icon(
                    Icons.favorite,
                    size: 30,
                    color: Colors.green,
                  ),
                  Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.blue,
                  ),
                  if (isFarmer)
                    Icon(
                      CupertinoIcons.rectangle_grid_2x2,
                      size: 30,
                      color: Colors.green,
                    ),
                ],
                onTap: (index) {
                  if (!isFarmer && index == 4) {
                    return;
                  }
                  _pageController.animateToPage(index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut);
                },
              ),
            ),
          );
        }
      },
    );
  }
}
