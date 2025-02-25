import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'club_list_page.dart';

class DivisionListPage extends StatefulWidget {
  const DivisionListPage({super.key});

  @override
  State<DivisionListPage> createState() => _DivisionListPageState();
}

class _DivisionListPageState extends State<DivisionListPage> {
  late Future<List<Map<String, dynamic>>> _divisions;
  List<Map<String, dynamic>> _allDivisions = [];
  List<Map<String, dynamic>> _filteredDivisions = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _divisions = ApiService.fetchDivisions();
    _divisions.then((divisions) {
      setState(() {
        _allDivisions = divisions;
        _filteredDivisions = List.from(divisions);
      });
    });
  }

  void _filterDivisions(String query) {
    setState(() {
      _searchQuery = query;
      if (_searchQuery.isEmpty) {
        _filteredDivisions = List.from(_allDivisions);
      } else {
        _filteredDivisions = _allDivisions
            .where((division) => division['name']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Find your Division",
          style: TextStyle(
            fontFamily: "Abhaya Libre ExtraBold",
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterDivisions,
              decoration: InputDecoration(
                hintText: "Search for a division...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Division List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _divisions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No divisions found."));
                }

                return ListView.builder(
                  itemCount: _filteredDivisions.length,
                  itemBuilder: (context, index) {
                    final division = _filteredDivisions[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClubListPage(
                              divisionName: division['name'],
                              divisionId: division['_id'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA3B9CC),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/gtc.png',
                              width: 80,
                              height: 80,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                division['name'],
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
