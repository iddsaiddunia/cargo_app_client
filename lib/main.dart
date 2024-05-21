import 'package:cargo_app/nonAuth/login.dart';
import 'package:cargo_app/services/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey:
              "AIzaSyBJgGLr3yWB7bUxGcSXJ-ScpoUU7gx2bcc", // paste your api key here
          appId:
              "1:248834172948:android:807b6e043944c2a8a09f01", //paste your app id here
          messagingSenderId: "248834172948", //paste your messagingSenderId here
          projectId: "cargo-app-2b2b5", //paste your project id here
          storageBucket: "cargo-app-2b2b5.appspot.com"),
    );
  }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => DestinationProvider()),
    // Add more providers here if needed
  ], child: MyApp()));
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
