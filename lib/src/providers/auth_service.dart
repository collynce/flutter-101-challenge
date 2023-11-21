import 'dart:developer';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../globals.dart';

class AuthService {
  String? authToken;

  final Future<SharedPreferences> _localStorage =
      SharedPreferences.getInstance();

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/api/login'),
          headers: {
            'Accept': 'application/json'
          },
          body: {
            'email': email,
            'password': password,
            'device_name': await FlutterUdid.udid
          });

      log('error]: ${response.statusCode}');

      if (response.statusCode == 200) {
        dynamic data = json.decode(response.body);
        authToken = data['token'];

        final SharedPreferences localStorage = await _localStorage;
        localStorage.setString('token', authToken!);

        return true;
      } else {
        dynamic error = json.decode(response.body);
        throw error['message'];
      }
    } catch (e) {
      throw '$e';
    }
  }

  Future<bool> register(String name, String email, String password,
      String passwordConfirmation) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Accept': 'application/json'},
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'device_name': await FlutterUdid.udid
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        dynamic error = json.decode(response.body);
        throw error['message'];
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<void> logout() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/api/logout'),
          headers: Map<String, String>.from(await headers));

      if (response.statusCode == 200) {
        authToken = null;
        final SharedPreferences localStorage = await _localStorage;
        localStorage.remove('token');
      } else {
        dynamic error = json.decode(response.body);
        throw error['message'];
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<bool> isAuthenticated() async {
    final SharedPreferences localStorage = await _localStorage;
    String? authToken = localStorage.getString('token');
    return authToken != null;
  }

  Future<Map> get headers async {
    final SharedPreferences localStorage = await _localStorage;
    String? authToken = localStorage.getString('token');

    Map<String, String> headers = {
      'Authorization': 'Bearer $authToken',
      'Accept': 'application/json',
      'Content-type': 'application/json'
    };

    return headers;
  }
}
