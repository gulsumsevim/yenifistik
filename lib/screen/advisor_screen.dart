import 'package:flutter/material.dart';
import 'package:fistikpazar/screen/advisorarazi.dart';
import 'package:fistikpazar/screen/advisordigcon.dart';
import 'package:fistikpazar/screen/advisorpanel.dart';

void main() {
  runApp(MaterialApp(
    home: AdvisorPage(),
  ));
}

class AdvisorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panelim'),
        backgroundColor: Color.fromARGB(255, 255, 240, 219),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildListTile(
              context,
              icon: Icons.dashboard,
              title: 'Panelim',
              targetPage: PanelimPage(),
            ),
            _buildListTile(
              context,
              icon: Icons.landscape,
              title: 'Arazilerim',
              targetPage: ArazilerimPage(),
            ),
            _buildListTile(
              context,
              icon: Icons.support_agent,
              title: 'Dijital Danışman',
              targetPage: DigitalAdvisorScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {required IconData icon, required String title, required Widget targetPage}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Color.fromARGB(255, 255, 240, 219),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.green),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        },
      ),
    );
  }
}

