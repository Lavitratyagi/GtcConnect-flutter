import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'club_list_page.dart';

class DivisionListPage extends StatefulWidget {
  const DivisionListPage({super.key});

  @override
  State<DivisionListPage> createState() => _DivisionListPageState();
}

class _DivisionListPageState extends State<DivisionListPage> {
  late Future<List<String>> _divisions;
  List<String> _filteredDivisions = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _divisions = ApiService.fetchDivisions(); // Fetch divisions from backend
    _divisions.then((divisions) {
      setState(() {
        _filteredDivisions = divisions; // Initialize with all divisions
      });
    });
  }

  void _filterDivisions(String query) {
    setState(() {
      _searchQuery = query;
      _filteredDivisions = _searchQuery.isEmpty
          ? _filteredDivisions
          : _filteredDivisions
              .where((division) =>
                  division.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Find your Division",
          style: TextStyle(
            fontFamily: "Abhaya Libre ExtraBold", // Custom font
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false, // Align text to the left
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
            child: FutureBuilder<List<String>>(
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
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClubListPage(
                              divisionName: _filteredDivisions[index],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8), // Margin around the tile
                        padding: const EdgeInsets.all(16), // Padding inside the tile
                        decoration: BoxDecoration(
                          color: const Color(0xFFA3B9CC), // Background color
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2), // Shadow color
                              blurRadius: 6, // Blur radius
                              offset: const Offset(0, 3), // Shadow position
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                                'assets/images/gtc.png', // Replace with your image path
                                width: 80,
                                height: 80,
                              ),
                            const SizedBox(width: 16), // Space between icon and text
                            Expanded(
                              child: Text(
                                _filteredDivisions[index],
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
