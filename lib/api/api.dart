import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Api {
  static const String baseUrl = 'http://13.60.243.207/api';

  // Login API
  static Future<String?> login(String email, String password) async {
    final String apiUrl = '$baseUrl/login';
    final data = {
      'email': email,
      'password': password,
    };

    try {
      // Debugging print statements
      print('API Endpoint: $apiUrl');
      print('Request Data: ${jsonEncode(data)}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var loginResponse = jsonDecode(response.body);
        final token = loginResponse['token'];

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        return token;
      } else {
        print('Login failed with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Login Error: $e');
      return null;
    }
  }
}
