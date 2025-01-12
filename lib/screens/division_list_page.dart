import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'club_list_page.dart';

class DivisionListPage extends StatefulWidget {
  const DivisionListPage({Key? key}) : super(key: key);

  @override
  State<DivisionListPage> createState() => _DivisionListPageState();
}

class _DivisionListPageState extends State<DivisionListPage> {
  late Future<List<String>> _divisions;

  @override
  void initState() {
    super.initState();
    _divisions = ApiService.fetchDivisions(); // Fetch divisions from backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find your Division"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: _divisions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No divisions found."));
          }

          final divisions = snapshot.data!;
          return ListView.builder(
            itemCount: divisions.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Image.asset("assets/images/division_list.png"),
                title: Text(
                  divisions[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ClubListPage(divisionName: divisions[index]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
