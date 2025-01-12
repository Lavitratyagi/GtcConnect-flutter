import 'package:flutter/material.dart';

class ClubListPage extends StatelessWidget {
  final String divisionName;

  const ClubListPage({Key? key, required this.divisionName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$divisionName Clubs"),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "List of clubs for $divisionName",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
