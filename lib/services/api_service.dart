import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "http://192.168.1.10:3000"; // Replace with your backend URL

  static Future<List<String>> fetchDivisions() async {
    final response =
        await http.get(Uri.parse("$baseUrl/division/getAllDivisions"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception("Failed to load divisions");
    }
  }

  static Future<List<Map<String, dynamic>>> fetchClubsByDivision(
      String divisionName) async {
    final response = await http
        .get(Uri.parse('$baseUrl/division/getClubsByDivision/$divisionName'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception("Failed to load clubs");
    }
  }

  static Future<Map<String, dynamic>> fetchClubDetails(String clubId) async {
    final response = await http.get(Uri.parse('$baseUrl/club/details/$clubId'));

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Failed to load club details");
    }
  }

  Future<List<Map<String, dynamic>>> fetchHotEvents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/events/getall'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final events = data['events'] as List;

        // Filter events happening within the next 4 days
        final now = DateTime.now();
        final fourDaysFromNow = now.add(const Duration(days: 4));
        final hotEvents = events.where((event) {
          final eventDate = DateTime.parse(event['eventDate']);
          return eventDate.isAfter(now) && eventDate.isBefore(fourDaysFromNow);
        }).toList();

        return List<Map<String, dynamic>>.from(hotEvents);
      } else {
        throw Exception('Failed to fetch events: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllEvents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/events/getall'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final events = data['events'] as List;

        // No filtering applied, return all events
        return List<Map<String, dynamic>>.from(events);
      } else {
        throw Exception('Failed to fetch events: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }

  Future<String> fetchClubName(String clubId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/club/details/$clubId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['club_name']; // Extract club name from the response
      } else {
        throw Exception('Failed to fetch club details: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching club details: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchEventDetails(String eventId) async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/events/get/$eventId"));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load event details: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching event details: $e");
    }
  }
}
