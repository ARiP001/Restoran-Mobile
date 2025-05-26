import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

class BaseNetwork {
  static const String baseUrl = 'https://restaurant-api.dicoding.dev/';
  static final _logger = Logger();
  // Add more endpoints as needed
  static Future<List<Map<String, dynamic>>> getAll(String path) async {
    final uri = Uri.parse('$baseUrl/$path');
    _logger.i("GET ALL : $uri");
    
    try {
      final response = await http.get(uri).timeout(Duration(seconds: 10));
      _logger.i("Response: ${response.statusCode}");
      _logger.i("Body: ${response.body}");

      if (response.statusCode == 200){
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        final List<dynamic> jsonList = jsonBody['restaurants'];
        return jsonList.cast<Map<String, dynamic>>();
      }else {
        _logger.e("Error : ${response.statusCode}");
        throw Exception("Server Error : ${response.statusCode}");
      }
    } on TimeoutException{
      _logger.e("Request time out to $uri");
      throw Exception("Request Timedout");
    }
    catch (e) {
      _logger.e("Error fetching data from $uri : $e");
      throw Exception(
        "Error fetching data : $e"
      );
    }
  }
}