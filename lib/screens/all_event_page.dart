import 'package:flutter/material.dart';
import 'package:gtcconnect/services/api_service.dart';

class AllEventsPage extends StatefulWidget {
  const AllEventsPage({super.key});

  @override
  State<AllEventsPage> createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  late Future<List<Map<String, dynamic>>> _events;
  String _selectedFilter = 'Present'; // Default filter is 'Present'
  final Map<String, String> _clubNames = {}; // Store club names by clubId

  @override
  void initState() {
    super.initState();
    _events = ApiService().fetchAllEvents(); // Fetch all events
  }

  // Method to filter events
  List<Map<String, dynamic>> _filterEvents(List<Map<String, dynamic>> events) {
    DateTime now = DateTime.now();
    DateTime fiveDaysLater = now.add(const Duration(days: 5));
    
    if (_selectedFilter == 'Past') {
      // Filter past events
      return events.where((event) {
        DateTime eventDate = DateTime.parse(event['eventDate']);
        return eventDate.isBefore(now);
      }).toList();
    } else if (_selectedFilter == 'Present') {
      // Filter events within the next 5 days, including today
      return events.where((event) {
        DateTime eventDate = DateTime.parse(event['eventDate']);
        return eventDate.isAfter(now.subtract(const Duration(days: 1))) && eventDate.isBefore(fiveDaysLater);
      }).toList();
    } else {
      // Filter upcoming events (after 5 days)
      return events.where((event) {
        DateTime eventDate = DateTime.parse(event['eventDate']);
        return eventDate.isAfter(fiveDaysLater);
      }).toList();
    }
  }

  // Fetch club name using clubId
  Future<String> fetchClubName(String clubId) async {
    if (_clubNames.containsKey(clubId)) {
      return _clubNames[clubId]!;
    }

    try {
      final clubName = await ApiService().fetchClubName(clubId); // Fetch club name
      _clubNames[clubId] = clubName;
      return clubName;
    } catch (e) {
      throw Exception('Failed to fetch club name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Events',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter options
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'Past';
                    });
                  },
                  child: Text(
                    'Past',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _selectedFilter == 'Past' ? Colors.red : Colors.black,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'Present';
                    });
                  },
                  child: Text(
                    'Present',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _selectedFilter == 'Present' ? Colors.red : Colors.black,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'Upcoming';
                    });
                  },
                  child: Text(
                    'Upcoming',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _selectedFilter == 'Upcoming' ? Colors.red : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Event List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _events,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Center(child: Text('No events available'));
                } else {
                  final events = _filterEvents(snapshot.data!);
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final clubId = event['clubId'];

                      return FutureBuilder<String>(
                        future: fetchClubName(clubId),
                        builder: (context, clubSnapshot) {
                          if (clubSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (clubSnapshot.hasError) {
                            return Center(child: Text('Error fetching club name: ${clubSnapshot.error}'));
                          } else if (clubSnapshot.hasData) {
                            return EventTile(
                              eventLogo: event['eventPoster'] ?? 'assets/images/gtc.png',
                              eventName: event['eventName'],
                              clubName: clubSnapshot.data!,
                              eventDate: event['eventDate'].split('T')[0],
                              isOnline: event['eventType'] == 'Online',
                            );
                          } else {
                            return EventTile(
                              eventLogo: event['eventPoster'] ?? 'assets/images/gtc.png',
                              eventName: event['eventName'],
                              clubName: 'Unknown Club',
                              eventDate: event['eventDate'].split('T')[0],
                              isOnline: event['eventType'] == 'Online',
                            );
                          }
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
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
                  // Fallback to local image if network image fails
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
