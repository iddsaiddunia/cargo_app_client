import 'package:cargo_app/widgets.dart';
import 'package:flutter/material.dart';

class RidesHistoryPage extends StatefulWidget {
  const RidesHistoryPage({super.key});

  @override
  State<RidesHistoryPage> createState() => _RidesHistoryPageState();
}

class _RidesHistoryPageState extends State<RidesHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            const Text(
              "March 2024",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 20,
            ),
            HistoryCard(),
            HistoryCard()
          ],
        ),
      ),
    );
  }
}
