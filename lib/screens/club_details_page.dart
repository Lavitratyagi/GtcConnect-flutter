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
                    // Banner Image
                    Image.asset(
                      'assets/images/gtccore.png',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    // Logo (Circle Avatar)
                    Positioned(
                      bottom: -40,
                      left: MediaQuery.of(context).size.width / 2 - 50,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(club['club_image'] ?? ''),
                        backgroundColor: Colors.white,
                        onBackgroundImageError: (_, __) {
                          setState(() {});
                        },
                        child: club['club_image'] == null
                            ? Image.asset('assets/images/default_logo.png')
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60), // Space for the logo

                // Club Name
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    club['club_name'] ?? "Club Name",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                // About Section (Centered)
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

                // Club Heads (Square Images with Card Background and Margins)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeadCard(club['head1_name'] ?? '', club['head1_image']),
                      const SizedBox(width: 16), // Space between the cards
                      _buildHeadCard(club['head2_name'] ?? '', club['head2_image']),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Club Description
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    club['club_desc']?.isNotEmpty == true
                        ? club['club_desc']
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
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/default_head.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name.isNotEmpty ? name : "N/A",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                "CLUB HEAD",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
