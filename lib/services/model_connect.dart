import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> swipesToRecs({
  required String data,
}) async {

  final response = await http.post(
    Uri.parse('https://us-central1-flavr-4e17f.cloudfunctions.net/cre'),
    headers: {'Content-Type': 'application/json'},
    body: data,
  );

  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');

  if (response.statusCode == 200) {
    final recommendations = json.decode(response.body);
    final firstEntry = (recommendations as Map<String, dynamic>).entries.first;
    print('Top dish: ${firstEntry.key} with score ${firstEntry.value}');
    return recommendations;
  } else {
    throw Exception('Failed to load recommendations with status code: ${response.statusCode}');
  }
}