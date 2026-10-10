import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/portfolio';

  Future<List<String>> checkPrivacy(Uint8List bytes, String filename) async {
    var uri = Uri.parse('$baseUrl/privacy-check');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    
    var response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to check privacy: ${response.statusCode}');
    }
    
    final respStr = await response.stream.bytesToString();
    var data = jsonDecode(respStr);
    return List<String>.from(data['sanitized_queries'] ?? []);
  }

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

  static const String settingsUrl = 'http://127.0.0.1:8000/api/settings/serpapi';

  Future<Map<String, dynamic>> getSerpApiStatus() async {
    var response = await http.get(Uri.parse('$settingsUrl/status'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to get SerpApi status');
  }

  Future<Map<String, dynamic>> saveSerpApiKey(String apiKey) async {
    var response = await http.post(
      Uri.parse('$settingsUrl/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'api_key': apiKey}),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    final error = jsonDecode(response.body)['detail'] ?? 'Failed to connect';
    throw Exception(error);
  }

  Future<void> clearSerpApiKey() async {
    await http.post(Uri.parse('$settingsUrl/clear'));
  }

  Future<Map<String, dynamic>> analyzePortfolio(String aiMode, {bool forceRefresh = false}) async {
    var uri = Uri.parse('$baseUrl/analyze');
    var request = http.MultipartRequest('POST', uri);
    
    request.fields['ai_mode'] = aiMode;
    request.fields['force_refresh'] = forceRefresh.toString();
    
    var response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to analyze portfolio: ${response.statusCode}');
    }
    
    final respStr = await response.stream.bytesToString();
    return jsonDecode(respStr);
  }
}
