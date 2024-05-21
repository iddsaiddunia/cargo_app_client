import 'package:cargo_app/auth/account.dart';
import 'package:cargo_app/auth/history.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BottomBorderInputField extends StatelessWidget {
  final String title;
  final bool isPasswordInput;
  final TextEditingController controller;
  const BottomBorderInputField({
    super.key,
    required this.title,
    required this.isPasswordInput,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        obscureText: isPasswordInput,
        controller: controller,
        decoration: InputDecoration(
          hintText: title,
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 9),
          ),
        ),
      ),
    );
  }
}

class CustomePrimaryButton extends StatelessWidget {
  final String title;
  final bool isLoading;
  final Function()? press;
  final bool isWithOnlyBorder;
  const CustomePrimaryButton({
    super.key,
    required this.title,
    required this.press,
    required this.isWithOnlyBorder,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        width: double.infinity,
        height: 55.0,
        decoration: BoxDecoration(
          color: isWithOnlyBorder ? null : Colors.blue,
          border: Border.all(width: 1, color: Colors.blue),
          borderRadius: const BorderRadius.all(
            (Radius.circular(5)),
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                )
              : Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isWithOnlyBorder
                        ? const Color.fromARGB(255, 78, 78, 78)
                        : const Color.fromARGB(255, 247, 247, 247),
                  ),
                ),
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final Function() ontap;
  final IconData icon;
  const MenuButton({super.key, required this.ontap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: 55.0,
        height: 50.0,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              width: 1, color: const Color.fromARGB(255, 170, 170, 170)),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Icon(icon),
      ),
    );
  }
}

class LocationInputField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final Function()? ontap;
  const LocationInputField(
      {super.key,
      required this.title,
      required this.controller,
      required this.ontap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.2,
      height: 50.0,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 1,
          color: const Color.fromARGB(255, 170, 170, 170),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.abc),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                controller: controller,
                onTap: ontap,
                readOnly: true,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    // prefixIcon: const Icon(Icons.location_on),
                    hintText: title,
                    hintStyle: TextStyle(fontSize: 15),
                    border: InputBorder.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DriverCard extends StatelessWidget {
  final Function() onpress;
  final double truckSize;
  final double estimatedPrice;
  final String truckType;
  const DriverCard({
    super.key,
    required this.onpress,
    required this.truckSize,
    required this.estimatedPrice,
    required this.truckType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.0,
      height: 140.0,
      padding: const EdgeInsets.all(7.0),
      margin: const EdgeInsets.all(7.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 1,
          color: const Color.fromARGB(255, 170, 170, 170),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 50,
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color: const Color.fromARGB(255, 170, 170, 170)),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Image.asset(
                  "assets/img/cargo-truck (1).png",
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 65,
                    height: 25,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 82, 82, 82),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Center(
                      child: Text(
                        "${truckSize.toString()} TON",
                        style: TextStyle(
                            color: Color.fromARGB(255, 233, 233, 233),
                            fontSize: 9,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 18,
                        color: Color.fromARGB(255, 228, 206, 13),
                      ),
                      Icon(
                        Icons.star,
                        size: 18,
                        color: Color.fromARGB(255, 228, 206, 13),
                      ),
                      Icon(
                        Icons.star,
                        size: 18,
                        color: Color.fromARGB(255, 228, 206, 13),
                      ),
                      Icon(
                        Icons.star,
                        size: 18,
                        color: Color.fromARGB(255, 228, 206, 13),
                      ),
                      Icon(
                        Icons.star,
                        size: 18,
                        color: Color.fromARGB(255, 228, 206, 13),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 25,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: const Color.fromARGB(255, 170, 170, 170),
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(4),
                  ),
                ),
                child: Center(
                  child: Text(
                    truckType.toUpperCase(),
                    style: TextStyle(
                        color: Color.fromARGB(255, 58, 58, 58),
                        fontSize: 9,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Text(
                "${estimatedPrice.toString()} Tsh",
                style: TextStyle(
                    color: Color.fromARGB(255, 58, 58, 58),
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
          const SizedBox(
            height: 6.0,
          ),
          GestureDetector(
            onTap: onpress,
            child: Container(
              width: 200.0,
              height: 35,
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: const Center(
                child: Text(
                  "Request",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  final Function() ontap;
  const CustomDrawer({
    super.key,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Row(
        children: <Widget>[
          Container(
            width: 300,
            color: Colors.white,
            child: SafeArea(
              child: Drawer(
                backgroundColor: Colors.white,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Container(
                      height: 80.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 26,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("John Doe"),
                                Text("+255768906543")
                              ],
                            ),
                          ),
                          IconButton(
                              onPressed: ontap,
                              icon: const Icon(Icons.arrow_forward_ios))
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('My Account'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountPage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock_clock),
                      title: const Text('My Rides'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RidesHistoryPage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('About'),
                      onTap: () {
                        // Handle item 3 tap
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(),
          ),
        ],
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70.0,
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom:
              BorderSide(width: 1, color: Color.fromARGB(255, 224, 224, 224)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 60,
            height: 55,
            padding: const EdgeInsets.all(9.0),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: const Color.fromARGB(255, 150, 150, 150),
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(7.0),
              ),
            ),
            child: Image.asset(
              "assets/img/cargo-truck (1).png",
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Airport Dar es salaam",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text("11 Mar, 16:06"),
            ],
          ),
          const Text("22k Tsh")
        ],
      ),
    );
  }
}
