import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:js_interop';
import '../config/api_config.dart';

// JavaScript interop for making requests with HttpOnly cookies
@JS()
external JSPromise<JSAny?> _makeRequestWithCookies(
    JSString url, JSString method, JSString? body, JSAny headers);

class JSAuthService {
  // WordPress API endpoint (same-origin)
  static String get baseUrl => ApiConfig.wordPressApiPath;

  // Make HTTP request through JavaScript to include HttpOnly cookies
  static Future<Map<String, dynamic>?> makeJSRequest(
    String url, {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    if (!kIsWeb) {
      print('JavaScript requests only available on web platform');
      return null;
    }

    try {
      print('🌐 JS Request: $method $url');

      // Prepare headers
      final jsHeaders = <String, String>{
        'Content-Type': 'application/json',
        ...?headers,
      }.jsify() as JSAny;

      // Prepare body
      JSString? jsBody;
      if (body != null) {
        jsBody = jsonEncode(body).toJS;
      }

      // Make the request
      final response = await _makeRequestWithCookies(
        url.toJS,
        method.toJS,
        jsBody,
        jsHeaders,
      ).toDart;

      print('📨 Raw JS response: $response');

      if (response != null) {
        try {
          final dartified = response.dartify();
          print('🔄 Dartified: $dartified (${dartified.runtimeType})');

          Map<String, dynamic> responseMap;

          if (dartified is Map<String, dynamic>) {
            responseMap = dartified;
          } else if (dartified is Map) {
            responseMap = Map<String, dynamic>.from(dartified);
          } else {
            print('❌ Unexpected response type: ${dartified.runtimeType}');
            return null;
          }

          final status = responseMap['status'] as int?;
          print('📊 Status: $status');

          if (status != null && status >= 200 && status < 300) {
            final data = responseMap['data'];
            if (data != null) {
              // Check if data is a JSON string that needs parsing
              if (data is String) {
                try {
                  final parsed = jsonDecode(data);
                  print('✅ Parsed JSON string data: $parsed');
                  // Return the parsed data directly (not wrapped in 'data')
                  if (parsed is Map<String, dynamic>) {
                    return parsed;
                  } else {
                    return {'data': parsed};
                  }
                } catch (e) {
                  print('❌ Failed to parse JSON string: $e');
                  return {'data': data};
                }
              } else if (data is Map<String, dynamic>) {
                print('✅ Parsed data: $data');
                return data;
              } else if (data is Map) {
                final parsed = Map<String, dynamic>.from(data);
                print('✅ Parsed data: $parsed');
                return parsed;
              } else if (data is List) {
                // For list responses, wrap in a data field
                final parsed = {'data': data};
                print('✅ Parsed data: $parsed');
                return parsed;
              } else {
                // For primitive types, wrap in a data field
                final parsed = {'data': data};
                print('✅ Parsed data: $parsed');
                return parsed;
              }
            }
          } else {
            print('❌ Request failed with status: $status');
            // Try to parse error response
            final data = responseMap['data'];
            if (data is String) {
              try {
                final parsed = jsonDecode(data);
                print('⚠️ Error response: $parsed');
                if (parsed is Map<String, dynamic>) {
                  return parsed;
                }
              } catch (e) {
                print('❌ Failed to parse error response: $e');
              }
            }
            return {
              'success': false,
              'message': 'Request failed with status $status'
            };
          }
        } catch (e) {
          print('💥 Response parsing error: $e');
        }
      }
      return null;
    } catch (e) {
      print('💥 JavaScript request error: $e');
      return null;
    }
  }

  // Get current user using JavaScript interop
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      print('🚀 Getting user via JavaScript...');
      return await makeJSRequest('$baseUrl/auth/me');
    } catch (e) {
      print('❌ JavaScript authentication error: $e');
      return null;
    }
  }
}
