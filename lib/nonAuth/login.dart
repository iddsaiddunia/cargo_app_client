import 'package:cargo_app/nonAuth/siginup.dart';
import 'package:cargo_app/widgets.dart';
import 'package:cargo_app/wrapper.dart';
import 'package:flutter/material.dart';

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

  Future<void> authenticateUser() async {
    // Simulate a login request
    setState(() {
      isLoading = true;
    });

    await Future.delayed(Duration(seconds: 2)); // Simulate network delay

    // Replace this with your actual authentication logic
    if (emailController.text == 'user@mail.com' &&
        passwordController.text == '1234') {
      // Authentication successful, navigate to the next page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Wrapper(
            isSignedIn: true,
          ),
        ),
      );
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

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        authenticateUser();
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
}
