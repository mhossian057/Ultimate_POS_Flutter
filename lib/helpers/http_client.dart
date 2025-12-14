import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_logger.dart';

class LoggedHttpClient {
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    ApiLogger.logRequest(
      method: 'POST',
      url: url.toString(),
      headers: headers,
      body: body,
    );
    
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      );
      
      stopwatch.stop();
      
      ApiLogger.logResponse(
        method: 'POST',
        url: url.toString(),
        statusCode: response.statusCode,
        body: response.body,
        duration: stopwatch.elapsedMilliseconds,
      );
      
      return response;
    } catch (e) {
      stopwatch.stop();
      
      ApiLogger.logError(
        method: 'POST',
        url: url.toString(),
        error: e.toString(),
      );
      
      rethrow;
    }
  }

  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    ApiLogger.logRequest(
      method: 'GET',
      url: url.toString(),
      headers: headers,
    );
    
    try {
      final response = await http.get(url, headers: headers);
      
      stopwatch.stop();
      
      ApiLogger.logResponse(
        method: 'GET',
        url: url.toString(),
        statusCode: response.statusCode,
        body: response.body,
        duration: stopwatch.elapsedMilliseconds,
      );
      
      return response;
    } catch (e) {
      stopwatch.stop();
      
      ApiLogger.logError(
        method: 'GET',
        url: url.toString(),
        error: e.toString(),
      );
      
      rethrow;
    }
  }

  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    ApiLogger.logRequest(
      method: 'PUT',
      url: url.toString(),
      headers: headers,
      body: body,
    );
    
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      );
      
      stopwatch.stop();
      
      ApiLogger.logResponse(
        method: 'PUT',
        url: url.toString(),
        statusCode: response.statusCode,
        body: response.body,
        duration: stopwatch.elapsedMilliseconds,
      );
      
      return response;
    } catch (e) {
      stopwatch.stop();
      
      ApiLogger.logError(
        method: 'PUT',
        url: url.toString(),
        error: e.toString(),
      );
      
      rethrow;
    }
  }

  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    ApiLogger.logRequest(
      method: 'DELETE',
      url: url.toString(),
      headers: headers,
      body: body,
    );
    
    try {
      final response = await http.delete(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      );
      
      stopwatch.stop();
      
      ApiLogger.logResponse(
        method: 'DELETE',
        url: url.toString(),
        statusCode: response.statusCode,
        body: response.body,
        duration: stopwatch.elapsedMilliseconds,
      );
      
      return response;
    } catch (e) {
      stopwatch.stop();
      
      ApiLogger.logError(
        method: 'DELETE',
        url: url.toString(),
        error: e.toString(),
      );
      
      rethrow;
    }
  }
}