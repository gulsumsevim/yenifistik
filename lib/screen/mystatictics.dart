import 'package:flutter/material.dart';
import 'product_statistics_screen.dart';
import 'field_statistics_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 240, 219),
        title: Text('İstatistiklerim'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          
          SizedBox(height: 16.0),
          Card(
            color: Color.fromARGB(255, 255, 240, 219),
            child: ListTile(
              leading: Icon(Icons.landscape, color: Colors.black),
              title: Text(
                'Arazi İstatistikleri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
              onTap: () {
                  Navigator.push(
                    
                  context,
                  MaterialPageRoute(
                    
                      builder: (context) => MaterialApp(
                          debugShowCheckedModeBanner: false,
                        
                        localizationsDelegates: [
                          
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        supportedLocales: [
                          const Locale('tr', 'TR'), // Türkçe
                        ],
                        locale: const Locale('tr', 'TR'),
                        home: FieldStatisticsScreen(),
                      )),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
































