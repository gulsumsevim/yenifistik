import 'package:fistikpazar/screen/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';




void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  ).then((_) {
    runApp( FistikPazar());
  });
}

class FistikPazar extends StatelessWidget {
  const FistikPazar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fıstık Pazar',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  SplashScreen(),
    );
  }
}
