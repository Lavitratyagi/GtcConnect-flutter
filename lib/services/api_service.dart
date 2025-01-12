import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.12:3000"; // Replace with your backend URL

  static Future<List<String>> fetchDivisions() async {
    final response = await http.get(Uri.parse("$baseUrl/divisions"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception("Failed to load divisions");
    }
  }
}
