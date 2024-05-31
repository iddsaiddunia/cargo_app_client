import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Icon(
            Icons.notifications_none,
            size: 40.0,
          ),
          Center(
            child: Text("Currently you have no notifications!"),
          ),
        ],
      ),
    );
  }
}