import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = await AuthStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<dynamic> get(String path, {bool withAuth = true}) async {
    final res = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(withAuth: withAuth),
    );
    return _handle(res);
  }

  static Future<dynamic> post(String path, {Object? body, bool withAuth = true}) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(body ?? {}),
    );
    return _handle(res);
  }

  static Future<dynamic> put(String path, {Object? body, bool withAuth = true}) async {
    final res = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(body ?? {}),
    );
    return _handle(res);
  }

  static Future<dynamic> delete(String path, {bool withAuth = true}) async {
    final res = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(withAuth: withAuth),
    );
    return _handle(res);
  }

  static dynamic _handle(http.Response res) {
    dynamic data;
    try {
      data = jsonDecode(res.body);
    } catch (_) {
      data = null;
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }

    final message = data is Map && data['error'] != null
        ? data['error'] as String
        : 'Error inesperado (${res.statusCode})';
    throw ApiException(message, statusCode: res.statusCode);
  }
}