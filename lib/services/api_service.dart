import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.10:3000"; // Replace with your backend URL

  static Future<List<String>> fetchDivisions() async {
    final response = await http.get(Uri.parse("$baseUrl/division/getAllDivisions"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception("Failed to load divisions");
    }
  }

  static Future<List<Map<String, dynamic>>> fetchClubsByDivision(
      String divisionName) async {
    final response =
        await http.get(Uri.parse('$baseUrl/division/getClubsByDivision/$divisionName'));
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
}
