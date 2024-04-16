import 'package:cargo_app/auth/driver_info.dart';
import 'package:cargo_app/auth/history.dart';
import 'package:cargo_app/auth/home.dart';
import 'package:cargo_app/auth/trucks_view.dart';
import 'package:cargo_app/nonAuth/login.dart';
import 'package:cargo_app/nonAuth/siginup.dart';
import 'package:cargo_app/wrapper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.purpleAccent),
        primaryColor: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
