import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fistikpazar/screen/admin.dart';
import 'package:fistikpazar/screen/advisor_screen.dart';
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

  Future<int?> _getRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('roleId');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _getRoleId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Bir hata oluştu.'));
        } else {
          int? roleId = snapshot.data;

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
                  if (roleId == 2) PanelPage(), // Farmer panel
                  if (roleId == 3) AdvisorPage(), // Advisor panel
                  if (roleId == 7) AdminPage(), // Admin panel
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
                  if (roleId == 2)
                    Icon(
                      CupertinoIcons.rectangle_grid_2x2,
                      size: 30,
                      color: Colors.green,
                    ),
                  if (roleId == 3)
                    Icon(
                      Icons.assessment,
                      size: 30,
                      color: Colors.green,
                    ),
                  if (roleId == 7)
                    Icon(
                      Icons.admin_panel_settings,
                      size: 30,
                      color: Colors.green,
                    ),
                ],
                onTap: (index) {
                  int pageIndex = index;
                  if (roleId == 2 && index == 4) {
                    pageIndex = 4; // Farmer panel
                  } else if (roleId == 3 && index == 4) {
                    pageIndex = 5; // Advisor panel
                  } else if (roleId == 7 && index == 4) {
                    pageIndex = 6; // Admin panel
                  } else if (index >= 4) {
                    return; // Invalid access for non-authorized roles
                  }
                  _pageController.animateToPage(pageIndex,
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
