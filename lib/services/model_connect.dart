import 'package:http/http.dart' as http;
import 'dart:convert';

Future<dynamic> swipesToRec({
  required String data,
}) async {

  final response = await http.post(
    Uri.parse('https://us-central1-flavr-4e17f.cloudfunctions.net/cre'),
    headers: {'Content-Type': 'application/json'},
    body: data,
  );

  print("Status: ${response.statusCode}");
  print("Body: ${response.body}");

  if (response.statusCode == 200) {
    final recommendations = json.decode(response.body);
    final firstEntry = (recommendations as Map<String, dynamic>).entries.first;
    print("Top dish: ${firstEntry.key} with score ${firstEntry.value}");
    return firstEntry.key;
  } else {
    throw Exception('Failed to load places with text search');
  }
}