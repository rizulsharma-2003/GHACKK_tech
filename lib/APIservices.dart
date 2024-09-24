import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://api.tvmaze.com';

Future<List> fetchAllMovies() async {
  final String endPoint = '/search/shows?q=all';
  final response = await http.get(Uri.parse('$baseUrl$endPoint'));

  print('Fetch All Movies - Status Code: ${response.statusCode}');
  print('Fetch All Movies - Response Body: ${response.body}');

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load movies');
  }
}

Future<List> searchMovies(String searchTerm) async {
  final String endPoint = '/search/shows?q=$searchTerm';
  final response = await http.get(Uri.parse('$baseUrl$endPoint'));

  print('Search Movies - Status Code: ${response.statusCode}');
  print('Search Movies - Response Body: ${response.body}');

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to search movies');
  }
}
