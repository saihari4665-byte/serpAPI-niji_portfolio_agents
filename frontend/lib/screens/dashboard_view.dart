import 'package:flutter/material.dart';
import '../widgets/health_score_card.dart';
import '../widgets/quick_stats_card.dart';
import '../widgets/asset_allocation_chart.dart';
import '../widgets/risk_alerts_card.dart';
import '../widgets/ai_briefing_panel.dart';

class DashboardView extends StatelessWidget {
  final Map<String, dynamic>? scanData;
  final bool isScanning;
  final bool isAnalyzing;
  final String? analysisMarkdown;
  final VoidCallback onUploadPressed;

  const DashboardView({
    super.key,
    required this.scanData,
    required this.isScanning,
    required this.isAnalyzing,
    required this.analysisMarkdown,
    required this.onUploadPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (scanData == null && !isScanning) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Upload a portfolio CSV to begin.", style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onUploadPressed,
              icon: const Icon(Icons.upload_file),
              label: const Text("Import CSV"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
            )
          ]
        ),
      );
    }
    
    if (isScanning) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
        ),
      );
    }

    return Row(
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3, 
                      child: HealthScoreCard(
                        score: scanData!['health_score'] as int? ?? 0, 
                        grade: scanData!['health_grade'] as String? ?? '-', 
                        status: scanData!['health_status'] as String? ?? 'Unknown'
                      )
                    ),
                    const SizedBox(width: 24),
                    Expanded(flex: 7, child: QuickStatsCard(scanData: scanData!)),
                  ],
                ),
                const SizedBox(height: 24),
                AssetAllocationChart(scanData: scanData!),
                const SizedBox(height: 24),
                const RiskAlertsCard(),
              ],
            ),
          ),
        ),
        // RIGHT PANEL (Flex 5)
        Expanded(
          flex: 5,
          child: AiBriefingPanel(
            isAnalyzing: isAnalyzing,
            markdownContent: analysisMarkdown,
            scanDataAvailable: scanData != null,
          ),
        ),
      ],
    );
  }
}
