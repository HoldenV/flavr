import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<List<dynamic>> textSearchPlaces({
  required String query,
  required double latitude,
  required double longitude,
  required String apiKey,
  required int radius, // In METERS
}) async {
  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/place/textsearch/json'
    '?query=${Uri.encodeComponent(query)}'
    '&location=$latitude,$longitude'
    '&radius=$radius'
    '&key=$apiKey',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['results'];
  } else {
    throw Exception('Failed to load places with text search');
  }
}

Image getPlacePhoto(String photoReference, String apiKey, {int maxWidth = 400}) {
  final url = 'https://maps.googleapis.com/maps/api/place/photo'
      '?maxwidth=$maxWidth'
      '&photo_reference=$photoReference'
      '&key=$apiKey';

  return Image.network(
    url,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return const Icon(Icons.broken_image, size: 48);
    },
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return const Center(child: CircularProgressIndicator());
    },
  );
}


Future<String> getApiKey() async {
  final jsonString = await rootBundle.loadString('lib/assets/secret.json');
  final data = json.decode(jsonString);
  return data['API_KEY'];
}
