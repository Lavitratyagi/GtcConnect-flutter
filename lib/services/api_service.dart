import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "http://192.168.1.4:3000"; // Replace with your backend URL

  static Future<List<Map<String, dynamic>>> fetchDivisions() async {
    final response =
        await http.get(Uri.parse("$baseUrl/division/getAllDivisions"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
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
        final events = List<Map<String, dynamic>>.from(data['events']);

        for (var event in events) {
          // Convert eventDate from string to DateTime
          event['eventDate'] = DateTime.parse(event['eventDate']).toLocal();
        }

        return events;
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
    final Uri url = Uri.parse('$baseUrl/events/get/$eventId');
    print(url);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load event details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching event details: $e');
    }
  }

  static Future<String> loginUser(
      String usernameOrEmail, String password) async {
    final url = Uri.parse('$baseUrl/users/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Assume the backend returns a JSON with a token property.
      return data['token'];
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchDivisionCoreDetails(
      String divisionId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/division/getCoreDetails/$divisionId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load division core details");
    }
  }

  static Future<String> createEvent(Map<String, dynamic> eventData,
      {File? posterImage}) async {
    if (posterImage != null) {
      // Use multipart request when an image is selected.
      var request =
          http.MultipartRequest("POST", Uri.parse('$baseUrl/events/create'));

      // Add text fields
      eventData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add the image file.
      request.files.add(
          await http.MultipartFile.fromPath('posterImage', posterImage.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 201) {
        return "Event created successfully";
      } else {
        throw Exception("Failed to create event: ${response.body}");
      }
    } else {
      // No image file, send regular JSON.
      final response = await http.post(
        Uri.parse('$baseUrl/events/create'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(eventData),
      );
      if (response.statusCode == 201) {
        return "Event created successfully";
      } else {
        throw Exception("Failed to create event: ${response.body}");
      }
    }
  }
}
