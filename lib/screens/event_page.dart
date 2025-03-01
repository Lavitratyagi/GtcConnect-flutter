import 'package:flutter/material.dart';
import 'package:gtcconnect/screens/all_event_page.dart';
import 'package:gtcconnect/services/api_service.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  late Future<List<Map<String, dynamic>>> _hotEvents;

  @override
  void initState() {
    super.initState();
    _hotEvents = ApiService().fetchAllEvents(); // Fetch events
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Events',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Connect, Network and Create',
              style: TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),

          // Banner Section
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/gtc_background.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Positioned(
                top: 16,
                left: 32,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INTERESTS!',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your Registered',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text(
                      'EVENTS!',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 8,
                left: 32,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Registered Events (if needed)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'VIEW',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Hot Events Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hot Events',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AllEventsPage()),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                        fontSize: 24, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Event List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _hotEvents,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Center(child: Text('No upcoming events'));
                }

                final events = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];

                    return EventTile(
                      eventLogo: event['eventPoster'] ?? 'assets/images/gtc.png',
                      eventName: event['eventName'] ?? 'Unknown Event',
                      clubName: (event['club'] != null && event['club']['name'] != null)
                          ? event['club']['name']
                          : 'Unknown Club',
                      eventDate: event['eventDate'] != null
                          ? _formatDate(event['eventDate'])
                          : "Unknown Date",
                      isOnline: event['eventType'] == 'Online',
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

  // Helper function to format date
  String _formatDate(dynamic eventDate) {
    try {
      if (eventDate is String) {
        return DateTime.parse(eventDate).toLocal().toString().split(' ')[0];
      } else if (eventDate is DateTime) {
        return eventDate.toLocal().toString().split(' ')[0];
      }
    } catch (e) {
      return "Unknown Date"; // Fallback in case of errors
    }
    return "Unknown Date";
  }
}

class EventTile extends StatelessWidget {
  final String eventLogo;
  final String eventName;
  final String clubName;
  final String eventDate;
  final bool isOnline;

  const EventTile({
    required this.eventLogo,
    required this.eventName,
    required this.clubName,
    required this.eventDate,
    required this.isOnline,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Event Logo with error handling for invalid URL
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                eventLogo,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/gtc.png', // Default image
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),

            // Event Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    clubName,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    eventDate,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Online/Offline Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isOnline ? 'ONLINE' : 'OFFLINE',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
