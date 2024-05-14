import 'package:cargo_app/nonAuth/siginup.dart';
import 'package:cargo_app/services/auth.dart';
import 'package:cargo_app/services/provider.dart';
import 'package:cargo_app/widgets.dart';
import 'package:cargo_app/wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

AuthService auth = AuthService();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 2,
            color: Colors.blue,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(),
                Container(
                  width: double.infinity,
                  // height: 300.0,
                  padding: const EdgeInsets.symmetric(
                      vertical: 30.0, horizontal: 15),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue,
                        blurRadius: 1.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                  child: Column(children: [
                    BottomBorderInputField(
                      controller: emailController,
                      title: "Email",
                    ),
                    BottomBorderInputField(
                      controller: passwordController,
                      title: "Password",
                    ),
                    const SizedBox(
                      height: 60.0,
                    ),
                    CustomePrimaryButton(
                      title: "Login",
                      isLoading: isLoading,
                      press: () {
                        _logIn(userProvider);
                      },
                      isWithOnlyBorder: false,
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    CustomePrimaryButton(
                      title: "Signup",
                      isLoading: isLoading,
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegistrationPage()),
                        );
                      },
                      isWithOnlyBorder: true,
                    ),
                  ]),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _logIn(UserProvider userProvider) async {
    // Simulate a login request
    setState(() {
      isLoading = true;
    });

    // await Future.delayed(Duration(seconds: 2));

    // Replace this with your actual authentication logic
    if (emailController.text != '' || passwordController.text != '') {
      // Authentication successful, navigate to the next page
      final user = await auth.signInUser(
          emailController.text, passwordController.text, userProvider);
      if (user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Wrapper(
              isSignedIn: true,
            ),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // Authentication failed, show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Authentication Failed'),
            content: Text('Invalid username or password.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
