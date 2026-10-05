import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/portfolio';

  Future<Map<String, dynamic>> uploadPortfolio(Uint8List bytes, String filename) async {
    var uri = Uri.parse('$baseUrl/upload');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    
    var response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to upload portfolio: ${response.statusCode}');
    }
    
    final respStr = await response.stream.bytesToString();
    return jsonDecode(respStr);
  }

  Future<Map<String, dynamic>> scanPortfolio() async {
    var uri = Uri.parse('$baseUrl/scan');
    var response = await http.post(uri);
    
    if (response.statusCode != 200) {
      throw Exception('Failed to scan portfolio: ${response.statusCode}');
    }
    return jsonDecode(response.body);
  }

  Future<String> analyzePortfolio() async {
    var uri = Uri.parse('$baseUrl/analyze');
    var response = await http.post(uri);
    
    if (response.statusCode != 200) {
      throw Exception('Failed to analyze portfolio: ${response.statusCode}');
    }
    var data = jsonDecode(response.body);
    return data['analysis'] ?? 'No analysis returned.';
  }
}
