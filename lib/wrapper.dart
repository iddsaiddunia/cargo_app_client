import 'package:cargo_app/auth/home.dart';
import 'package:cargo_app/nonAuth/siginup.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  final bool isSignedIn;
  const Wrapper({super.key, required this.isSignedIn});

  @override
  Widget build(BuildContext context) {
    if (isSignedIn) {
      return const HomePage();
    } else {
      return const RegistrationPage();
    }
  }
}
