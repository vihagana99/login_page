import 'package:flutter/material.dart';
import 'login_page.dart'; // Ensure this is the correct path to your login page file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login',
      home: LoginPage(),
    );
  }
}
