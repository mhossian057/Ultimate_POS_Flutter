import 'package:flutter/foundation.dart';

class ApiLogger {
  static void logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    if (!kDebugMode) return;
    
    final sanitizedHeaders = _sanitizeHeaders(headers);
    final bodyStr = body != null ? body.toString() : 'null';
    
    print('🌐 API ➡️ $method $url');
    print('📋 Headers: $sanitizedHeaders');
    print('📦 Body: $bodyStr');
    print(''); // Empty line for separation
  }
  
  static void logResponse({
    required String method,
    required String url,
    required int statusCode,
    required String body,
    int? duration,
  }) {
    if (!kDebugMode) return;
    
    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    final durationStr = duration != null ? ' (${duration}ms)' : '';
    
    print('🌐 API $emoji $method $url → $statusCode$durationStr');
    print('📥 Response: $body');
    print(''); // Empty line for separation
  }
  
  static void logError({
    required String method,
    required String url,
    required String error,
  }) {
    if (!kDebugMode) return;
    
    print('🌐 API 💥 $method $url → ERROR: $error');
    print(''); // Empty line for separation
  }
  
  static Map<String, String> _sanitizeHeaders(Map<String, String>? headers) {
    if (headers == null) return {};
    
    return headers.map((key, value) {
      // Hide sensitive information
      if (key.toLowerCase().contains('authorization') || 
          key.toLowerCase().contains('token')) {
        return MapEntry(key, '***hidden***');
      }
      return MapEntry(key, value);
    });
  }
  
}