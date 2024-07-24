import 'package:cargo_app/nonAuth/login.dart';
import 'package:cargo_app/services/auth.dart';
import 'package:cargo_app/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

AuthService auth = new AuthService();

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
  // void dispose(){
  //   // super.init()
  // }

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
                      controller: usernameController,
                      isPasswordInput: false,
                      title: "Username",
                    ),
                    BottomBorderInputField(
                      controller: emailController,
                      isPasswordInput: false,
                      title: "Email",
                    ),
                    BottomBorderInputField(
                      controller: phoneController,
                      isPasswordInput: false,
                      title: "Phone",
                    ),
                    BottomBorderInputField(
                      controller: passwordController,
                      isPasswordInput: true,
                      title: "Password",
                    ),
                    BottomBorderInputField(
                      controller: verifyController,
                      isPasswordInput: true,
                      title: "Retype Password",
                    ),
                    const SizedBox(
                      height: 60.0,
                    ),
                    CustomePrimaryButton(
                      title: "Sign up",
                      isLoading: isLoading,
                      press: _signUp,
                      isWithOnlyBorder: false,
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    CustomePrimaryButton(
                      title: "Login",
                      isLoading: false,
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

  _signUp() async {
    setState(() {
      isLoading = true;
    });
    if (usernameController.text != '' ||
        emailController.text != '' ||
        phoneController.text != '' ||
        passwordController.text != '' ||
        verifyController.text != '') {
      if (passwordController.text == verifyController.text) {
        final user = await auth.createNewUser(
            emailController.text, passwordController.text);
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('clients')
              .doc(user.uid)
              .set({
            'username': usernameController.text.trim(),
            'phone': phoneController.text.trim(),
          });
          _showToast(context, "successfully registered user");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );
          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          _showToast(context, "Failed to register user");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        _showToast(context, "Password not matching");
      }
    } else {
      setState(() {
        isLoading = false;
      });
      _showToast(context, "Please fill all fields");
    }
  }

  void _showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
}
