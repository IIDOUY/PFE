import 'package:flutter/material.dart';
import 'package:easelink/pages/welcomePage.dart';
// import 'pages/WelcomePage.dart';
void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const WelcomePage(),
    );
  }

}
