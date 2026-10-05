import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../widgets/app_header.dart';
import '../widgets/health_score_card.dart';
import '../widgets/quick_stats_card.dart';
import '../widgets/asset_allocation_chart.dart';
import '../widgets/risk_alerts_card.dart';
import '../widgets/ai_briefing_panel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();

  bool _isUploading = false;
  bool _isScanning = false;
  bool _isAnalyzing = false;
  
  Map<String, dynamic>? _scanData;
  String? _analysisMarkdown;
  String? _errorMessage;

  Future<void> _handleUpload() async {
    try {
      PlatformFile? file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (file == null) return;

      setState(() {
        _isUploading = true;
        _errorMessage = null;
        _scanData = null;
        _analysisMarkdown = null;
      });

      var bytes = await file.readAsBytes();
      if (bytes.isEmpty) throw Exception("Empty file.");

      await _apiService.uploadPortfolio(bytes, file.name);

      setState(() {
        _isUploading = false;
        _isScanning = true;
      });

      var scanData = await _apiService.scanPortfolio();

      setState(() {
        _isScanning = false;
        _scanData = scanData;
        _isAnalyzing = true;
      });

      var analysis = await _apiService.analyzePortfolio();

      setState(() {
        _isAnalyzing = false;
        _analysisMarkdown = analysis;
      });

    } catch (e) {
      setState(() {
        _isUploading = false;
        _isScanning = false;
        _isAnalyzing = false;
        _errorMessage = e.toString();
      });
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage!), backgroundColor: const Color(0xFFEF4444)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          AppHeader(
            onUploadPressed: _isUploading || _isScanning || _isAnalyzing ? null : _handleUpload,
          ),
          if (_isUploading) const LinearProgressIndicator(color: Color(0xFF4F46E5), minHeight: 2),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT PANEL (Flex 6)
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_scanData == null && !_isScanning)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: Text("Upload a portfolio CSV to begin.", style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 16)),
                            ),
                          ),
                        if (_isScanning)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                            ),
                          ),
                        if (_scanData != null) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(flex: 3, child: HealthScoreCard(score: 88, label: "Balanced Growth")),
                              const SizedBox(width: 24),
                              Expanded(flex: 7, child: QuickStatsCard(scanData: _scanData!)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          AssetAllocationChart(scanData: _scanData!),
                          const SizedBox(height: 24),
                          const RiskAlertsCard(),
                        ]
                      ],
                    ),
                  ),
                ),
                // RIGHT PANEL (Flex 5)
                Expanded(
                  flex: 5,
                  child: AiBriefingPanel(
                    isAnalyzing: _isAnalyzing,
                    markdownContent: _analysisMarkdown,
                    scanDataAvailable: _scanData != null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
