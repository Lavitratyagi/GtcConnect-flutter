import 'package:flutter/material.dart';
import 'package:gtcconnect/screens/event_detail.dart';
import 'package:gtcconnect/services/api_service.dart';

class AllEventsPage extends StatefulWidget {
  const AllEventsPage({super.key});

  @override
  State<AllEventsPage> createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  late Future<List<Map<String, dynamic>>> _events;
  String _selectedFilter = 'Present'; // Default filter is 'Present'
  final Map<String, String> _clubNames = {}; // Cache for club names

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
        return eventDate.isAfter(now.subtract(const Duration(days: 1))) && 
               eventDate.isBefore(fiveDaysLater);
      }).toList();
    } else {
      // Filter upcoming events (after 5 days)
      return events.where((event) {
        DateTime eventDate = DateTime.parse(event['eventDate']);
        return eventDate.isAfter(fiveDaysLater);
      }).toList();
    }
  }

  // Fetch club name using clubId and cache it
  Future<String> fetchClubName(String clubId) async {
    if (_clubNames.containsKey(clubId)) {
      return _clubNames[clubId]!;
    }
    try {
      final clubName = await ApiService().fetchClubName(clubId);
      _clubNames[clubId] = clubName;
      return clubName;
    } catch (e) {
      return 'Unknown Club';
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Filter options
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Past', 'Present', 'Upcoming'].map((filter) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _selectedFilter == filter ? Colors.red : Colors.black,
                    ),
                  ),
                );
              }).toList(),
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
                          }
                          final clubName = clubSnapshot.data ?? 'Unknown Club';
                          return EventTile(
                            eventLogo: event['eventPoster'],
                            eventName: event['eventName'] ?? '',
                            clubName: clubName,
                            eventDate: (event['eventDate'] ?? '').split('T')[0],
                            isOnline: (event['eventType'] ?? '').toString() == 'Online',
                            eventId: event['_id'],
                          );
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
  final String eventId;

  const EventTile({
    required this.eventLogo,
    required this.eventName,
    required this.clubName,
    required this.eventDate,
    required this.isOnline,
    required this.eventId,
    super.key,
  });

  // Helper method to choose the appropriate image widget.
  // If the eventLogo starts with "http", use Image.network; otherwise, use Image.asset.
  Widget buildEventLogo() {
    if (eventLogo.startsWith('http')) {
      return Image.network(
        eventLogo,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to asset image if network image fails.
          return Image.asset(
            'assets/images/gtc.png',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      return Image.asset(
        eventLogo.isNotEmpty ? eventLogo : 'assets/images/gtc.png',
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to EventDetailPage with the eventId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(eventId: eventId),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Event Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: buildEventLogo(),
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
      ),
    );
  }
}
