import 'package:flutter/material.dart';
import 'find_advisor_screen.dart';
import 'my_advisors_screen.dart';

class AdvisorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 240, 219),
        title: Text('Danışman'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(color: Color.fromARGB(255, 255, 240, 219),
            child: ListTile(

              leading: Icon(Icons.search, color: Colors.black),
              title: Text(
                'Danışman Bul',
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
                  MaterialPageRoute(builder: (context) => FindAdvisorScreen()),
                );
              },
            ),
          ),
          SizedBox(height: 16.0),
          Card(
            color: Color.fromARGB(255, 255, 240, 219),
            child: ListTile(
              leading: Icon(Icons.people, color: Colors.black),
              title: Text(
                'Danışmanlarım',
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
                  MaterialPageRoute(builder: (context) => MyAdvisorsScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
