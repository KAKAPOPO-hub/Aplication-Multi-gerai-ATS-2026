import 'dart:convert';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl =
      'https://5rtjfbbz-5000.asse.devtunnels.ms/';
  static const String _tokenKey = 'token';
  static http.Client _client = http.Client();

  @visibleForTesting
  static set clientForTesting(http.Client client) {
    _client = client;
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Respons login tidak valid');
    }

    if (response['success'] != true) {
      final message = response['message'];
      throw Exception(message is String ? message : 'Login gagal');
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Data login tidak valid');
    }

    final token = data['token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Token login tidak ditemukan');
    }

    await saveToken(token);
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : null;
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return body;
    }
    final message = body is Map
        ? body['message']
        : null;
    throw Exception(message ?? 'Terjadi kesalahan');
  }

  static Uri _uri(String endpoint) {
    final path = endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint;
    return Uri.parse('$_baseUrl/$path');
  }

  static Future<dynamic> get(String endpoint) async {
    final response = await _client.get(
      _uri(endpoint),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.post(
      _uri(endpoint),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.put(
      _uri(endpoint),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String endpoint) async {
    final response = await _client.delete(
      _uri(endpoint),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }
}