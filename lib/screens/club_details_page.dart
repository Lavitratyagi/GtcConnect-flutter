import 'package:flutter/material.dart';
import 'package:gtcconnect/screens/add_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../services/api_service.dart';

class ClubDetailsPage extends StatefulWidget {
  final String clubId;

  const ClubDetailsPage({required this.clubId, super.key});

  @override
  State<ClubDetailsPage> createState() => _ClubDetailsPageState();
}

class _ClubDetailsPageState extends State<ClubDetailsPage> {
  late Future<Map<String, dynamic>> _clubDetails;
  String _selectedTab = "About"; // Default tab is About
  bool _isPrivileged = false; // Flag for privileged users

  @override
  void initState() {
    super.initState();
    _clubDetails = ApiService.fetchClubDetails(widget.clubId);
    // Once the club details are fetched, check if the current user has privileges.
    _clubDetails.then((club) {
      _checkUserPermissions(club);
    });
  }
  
  Future<void> _checkUserPermissions(Map<String, dynamic> club) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      try {
        Map<String, dynamic> payload = Jwt.parseJwt(token);
        String userId = payload['userId'].toString();
        List<dynamic> clubHeads = club['clubHeads'] ?? [];
        List<dynamic> clubCoordinators = club['clubCoordinators'] ?? [];
        bool isPrivileged = clubHeads.any((head) => head['_id'].toString() == userId) ||
            clubCoordinators.any((coordinator) => coordinator['_id'].toString() == userId);
        setState(() {
          _isPrivileged = isPrivileged;
        });
      } catch (e) {
        print("Error decoding token: $e");
        setState(() {
          _isPrivileged = false;
        });
      }
    } else {
      setState(() {
        _isPrivileged = false;
      });
    }
  }

  // Build a card widget for a club head or coordinator.
  Widget _buildHeadCard(String name, String? imageUrl) {
    return Expanded(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          height: 180, // Increased height for the card
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/default_head.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/default_head.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                name.isNotEmpty ? name : "N/A",
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                "CLUB HEAD",
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the horizontal tab navigation bar with two buttons.
  Widget _buildTabNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedTab = "About";
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  child: Text(
                    "About",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _selectedTab == "About" ? Colors.red : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 30,
              color: Colors.black26,
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedTab = "Events";
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  child: Text(
                    "Events",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _selectedTab == "Events" ? Colors.red : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the About content: club heads, club coordinators, and club description.
  Widget _buildAboutContent(Map<String, dynamic> club) {
    final List<dynamic> clubHeads = club['clubHeads'] ?? [];
    final List<dynamic> clubCoordinators = club['clubCoordinators'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (clubHeads.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Club Heads",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        if (clubHeads.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: clubHeads.take(2).map((head) {
                return _buildHeadCard(
                  head['fullName'] ?? '',
                  head['avatar'] ?? '',
                );
              }).toList(),
            ),
          ),
        if (clubCoordinators.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Club Coordinators",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        if (clubCoordinators.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: clubCoordinators.take(2).map((coordinator) {
                return _buildHeadCard(
                  coordinator['fullName'] ?? '',
                  coordinator['avatar'] ?? '',
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            club['description']?.toString().isNotEmpty == true
                ? club['description']
                : "No description available.",
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  // Build the Events content placeholder.
  Widget _buildEventsContent(Map<String, dynamic> club) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Events coming soon.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Club Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey.shade200,
      floatingActionButton: (_selectedTab == "Events" && _isPrivileged)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEventPage(clubId: widget.clubId,)),
                );
              },
              child: const Icon(Icons.add),
              backgroundColor: Colors.red,
            )
          : null,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _clubDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No details available."));
          }

          final club = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Banner with Circle Avatar Logo
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Banner Image (a static asset)
                    Image.asset(
                      'assets/images/gtccore.png',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    // Positioned Logo (Circle Avatar) over the banner
                    Positioned(
                      bottom: -40,
                      left: MediaQuery.of(context).size.width / 2 - 50,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: club['clubLogo'] != null &&
                                club['clubLogo'].toString().isNotEmpty
                            ? NetworkImage(club['clubLogo'])
                            : const AssetImage('assets/images/default_logo.png') as ImageProvider,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60), // Space for the positioned logo
                // Club Name
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    club['name'] ?? "Club Name",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Tab Navigation Buttons (About & Events)
                _buildTabNavigation(),
                const SizedBox(height: 16),
                // Content based on selected tab
                _selectedTab == "About"
                    ? _buildAboutContent(club)
                    : _buildEventsContent(club),
              ],
            ),
          );
        },
      ),
    );
  }
}
