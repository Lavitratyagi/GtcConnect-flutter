import 'package:flutter/material.dart';
import 'package:gtcconnect/services/api_service.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;

  const EventDetailPage({required this.eventId, Key? key}) : super(key: key);

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late Future<Map<String, dynamic>> _eventDetails;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _updatesKey = GlobalKey();
  final GlobalKey _queriesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _eventDetails = ApiService.fetchEventDetails(widget.eventId);
  }

  // Scroll to a specific section using its GlobalKey.
  void _scrollToSection(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Build the club info in an oval container aligned to the left.
   Widget _buildClubInfo(Map<String, dynamic> club) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xff6E7D87),
            borderRadius: BorderRadius.circular(40),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Club Logo with transparent background.
              ClipOval(
                child: Container(
                  color: Colors.transparent, // Set the background of the image container to transparent.
                  child: (club['clubLogo'] != null &&
                          club['clubLogo'].toString().isNotEmpty &&
                          club['clubLogo'].toString().startsWith('http'))
                      ? Image.network(
                          club['clubLogo'],
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/gtc.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/gtc.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                club['clubName'] ?? 'Unknown Club',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the event poster (resized to a fixed height while preserving aspect ratio).
  Widget _buildEventPoster(String? posterUrl) {
    if (posterUrl != null && posterUrl.isNotEmpty && posterUrl.startsWith('http')) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(posterUrl),
            fit: BoxFit.contain,
          ),
        ),
      );
    } else {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: const DecorationImage(
            image: AssetImage('assets/images/gtc.png'),
            fit: BoxFit.contain,
          ),
        ),
      );
    }
  }

  // Build the horizontal navigation bar with rounded corners and visible dividers.
  Widget _buildNavigationBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _scrollToSection(_aboutKey),
                child: const Center(
                  child: Text(
                    "About",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              color: Colors.black54,
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),
            Expanded(
              child: InkWell(
                onTap: () => _scrollToSection(_updatesKey),
                child: const Center(
                  child: Text(
                    "Updates",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              color: Colors.black54,
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),
            Expanded(
              child: InkWell(
                onTap: () => _scrollToSection(_queriesKey),
                child: const Center(
                  child: Text(
                    "Queries",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the About section with event details and a Register button.
  Widget _buildAboutSection(Map<String, dynamic> event) {
    return Card(
      key: _aboutKey,
      color: Colors.grey.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.calendar_today, size: 20),
                SizedBox(width: 8),
                Text("Date:", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(event['eventDate'] ?? ''),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.access_time, size: 20),
                SizedBox(width: 8),
                Text("Time:", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(event['eventTime'] ?? ''),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.location_on, size: 20),
                SizedBox(width: 8),
                Text("Venue:", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(event['eventVenue'] ?? 'N/A'),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.event, size: 20),
                SizedBox(width: 8),
                Text("Type:", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(event['eventType'] ?? ''),
            const SizedBox(height: 8),
            if (event['prizes'] != null && event['prizes'].toString().isNotEmpty)
              Row(
                children: const [
                  Icon(Icons.money, size: 20),
                  SizedBox(width: 8),
                  Text("Prize:", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            if (event['prizes'] != null && event['prizes'].toString().isNotEmpty)
              Text("₹${event['prizes']}"),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Registration action here
                },
                child: const Text("Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the Updates section (prototype) as a card.
  Widget _buildUpdatesSection() {
    return Card(
      key: _updatesKey,
      color: Colors.grey.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Updates",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("No updates available at the moment."),
          ],
        ),
      ),
    );
  }

  // Build the Queries section (prototype) as a card.
  Widget _buildQueriesSection() {
    return Card(
      key: _queriesKey,
      color: Colors.grey.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Queries",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("User Query 1: What is the schedule?"),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("User Query 2: Is registration free?"),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Ask your question",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _eventDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        } else if (snapshot.hasData) {
          final event = snapshot.data!['event'];
          final club = snapshot.data!['club'];
          return Scaffold(
            appBar: AppBar(
              title: Text(event['eventName'] ?? 'Event Details'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            body: Column(
              children: [
                // Fixed top portion
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16), // Gap between AppBar and club info
                    // Club Info (aligned to left)
                    _buildClubInfo(club),
                    const SizedBox(height: 16),
                    // Event Poster
                    _buildEventPoster(event['eventPoster']),
                    const SizedBox(height: 16),
                    // Navigation Bar with rounded corners
                    _buildNavigationBar(),
                  ],
                ),
                // Scrollable content below the fixed portion
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildAboutSection(event),
                        const SizedBox(height: 16),
                        _buildUpdatesSection(),
                        const SizedBox(height: 16),
                        _buildQueriesSection(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text("No data found.")),
          );
        }
      },
    );
  }
}
