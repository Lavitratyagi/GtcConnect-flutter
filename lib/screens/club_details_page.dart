import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ClubDetailsPage extends StatefulWidget {
  final String clubId;

  const ClubDetailsPage({required this.clubId, super.key});

  @override
  State<ClubDetailsPage> createState() => _ClubDetailsPageState();
}

class _ClubDetailsPageState extends State<ClubDetailsPage> {
  late Future<Map<String, dynamic>> _clubDetails;

  @override
  void initState() {
    super.initState();
    _clubDetails = ApiService.fetchClubDetails(widget.clubId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Club Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
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
          // Get the club heads array (each head has fullName and avatar).
          final List<dynamic> clubHeads = club['clubHeads'] ?? [];

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
                            : const AssetImage('assets/images/default_logo.png')
                                as ImageProvider,
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
                const SizedBox(height: 16),
                // ABOUT Section Title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "ABOUT",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Club Heads Section (display up to 2 heads, if available)
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
                const SizedBox(height: 16),
                // Club Description
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
            ),
          );
        },
      ),
    );
  }

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
            mainAxisAlignment:
                MainAxisAlignment.center, // Center the content vertically
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
}
