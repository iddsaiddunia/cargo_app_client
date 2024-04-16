import 'package:cargo_app/widgets.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool isLoading = false;

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController verifyController = TextEditingController();

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
                        controller: usernameController, title: "Username"),
                    BottomBorderInputField(
                        controller: emailController, title: "Email"),
                    BottomBorderInputField(
                        controller: phoneController, title: "Phone"),
                    BottomBorderInputField(
                        controller: passwordController, title: "Password"),
                    BottomBorderInputField(
                        controller: verifyController, title: "Retype Password"),
                    const SizedBox(
                      height: 60.0,
                    ),
                    CustomePrimaryButton(
                      title: "Sign up",
                      isLoading: isLoading,
                      press: () {},
                      isWithOnlyBorder: false,
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    CustomePrimaryButton(
                      title: "Login",
                      isLoading: isLoading,
                      press: () {
                        Navigator.pop(context);
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
