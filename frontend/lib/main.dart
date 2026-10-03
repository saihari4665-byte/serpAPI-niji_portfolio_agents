import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const NijiPortfolioApp());
}

class NijiPortfolioApp extends StatelessWidget {
  const NijiPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Niji Portfolio Agent',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E2C),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _statusText = "Ready to scan.";
  String _analysis = "";
  bool _isLoading = false;

  Future<void> _uploadAndAnalyze() async {
    try {
      PlatformFile? file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (file == null) {
        return; // User canceled the picker
      }

      setState(() {
        _isLoading = true;
        _statusText = "Uploading portfolio...";
        _analysis = "";
      });

      // 1. Upload the CSV
      var uri = Uri.parse('http://127.0.0.1:8000/api/portfolio/upload');
      var request = http.MultipartRequest('POST', uri);
      
      var bytes = await file.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
          'file', bytes, filename: file.name));
            
      var response = await request.send();
      
      if (response.statusCode != 200) {
        throw Exception("Failed to upload portfolio. Status: ${response.statusCode}");
      }

      setState(() {
        _statusText = "Sanitizing tickers and querying SerpApi Live Markets...";
      });

      // 2. Call /analyze directly which triggers SerpApi and local LLM
      var analyzeUri = Uri.parse('http://127.0.0.1:8000/api/portfolio/analyze');
      var analyzeResponse = await http.post(analyzeUri);
      
      if (analyzeResponse.statusCode != 200) {
        throw Exception("Failed to analyze portfolio. Status: ${analyzeResponse.statusCode}");
      }
      
      var data = jsonDecode(analyzeResponse.body);
      
      setState(() {
        _statusText = "Analysis complete.";
        _analysis = data['analysis'] ?? "No analysis returned.";
      });
      
    } catch (e) {
      setState(() {
        _statusText = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Niji Portfolio Agent"),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green),
              ),
              child: const Text(
                "Privacy: AIR-GAPPED",
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _uploadAndAnalyze,
                icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Icon(Icons.upload_file),
                label: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Upload Portfolio & Run Intelligence Scan", style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _statusText,
              style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              "AI Executive Briefing",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade800),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withOpacity(0.5),
                ),
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _analysis.isEmpty ? "No briefing available yet." : _analysis,
                    style: const TextStyle(
                      fontFamily: 'Consolas',
                      color: Colors.greenAccent,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
