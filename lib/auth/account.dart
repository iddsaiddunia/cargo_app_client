import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(

                  child: Column(children: [
                CircleAvatar(
                  radius: 37,
                ),
                Text("John Doe",style: TextStyle(fontWeight: FontWeight.w600),),
                Text("+25578908765"),
                MaterialButton(
                  color: Colors.blue,
                  elevation: 0,
                  onPressed: (){}, child: Text("Edit profile",style: TextStyle(color: Colors.white, fontSize: 12),),),
              ],),),
            ],
          ),
          Divider()

        ],
      ),
    );
  }
}