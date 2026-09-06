import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
  static const Duration _timeout = Duration(seconds: 10);

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

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
    return _send('GET', path, headers: await _headers(withAuth: withAuth));
  }

  static Future<dynamic> post(String path, {Object? body, bool withAuth = true}) async {
    return _send('POST', path,
        headers: await _headers(withAuth: withAuth), body: body);
  }

  static Future<dynamic> put(String path, {Object? body, bool withAuth = true}) async {
    return _send('PUT', path,
        headers: await _headers(withAuth: withAuth), body: body);
  }

  static Future<dynamic> delete(String path, {bool withAuth = true}) async {
    return _send('DELETE', path, headers: await _headers(withAuth: withAuth));
  }

  static Future<dynamic> _send(
    String method,
    String path, {
    required Map<String, String> headers,
    Object? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    debugPrint('[API] $method → $uri${body != null ? ' body=$body' : ''}');
    http.Response res;
    try {
      switch (method) {
        case 'POST':
          res = await http
              .post(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(_timeout);
        case 'PUT':
          res = await http
              .put(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(_timeout);
        case 'DELETE':
          res = await http.delete(uri, headers: headers).timeout(_timeout);
        default:
          res = await http.get(uri, headers: headers).timeout(_timeout);
      }
    } on TimeoutException {
      throw ApiException('El servidor no respondió a tiempo');
    } on SocketException {
      throw ApiException('No se pudo conectar con el servidor');
    }
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