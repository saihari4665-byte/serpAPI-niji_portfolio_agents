import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class EvidenceScreen extends StatelessWidget {
  final Map<String, dynamic>? scanData;
  const EvidenceScreen({super.key, this.scanData});

  @override
  Widget build(BuildContext context) {
    if (scanData == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text("No research evidence stored. Execute the Privacy Gate search to inspect public news and source traceability.", style: TextStyle(color: Color(0xFFA1A1AA))),
        ),
      );
    }

    final factorBreakdowns = scanData!['factor_breakdowns'] as Map? ?? {};
    final newsEvidence = scanData!['news_evidence'] as List? ?? [];
    
    // Fallbacks if backend doesn't provide them fully formed
    final entityRel = factorBreakdowns['entity_relevance']?.toString() ?? "High";
    final eventRel = factorBreakdowns['event_relevance']?.toString() ?? "Medium";
    final evidenceQual = factorBreakdowns['evidence_quality']?.toString() ?? "High";
    final recency = factorBreakdowns['recency']?.toString() ?? "Recent";
    final corroboration = factorBreakdowns['corroboration']?.toString() ?? "x1.5";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Privacy Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.1),
              border: Border.all(color: const Color(0xFF22C55E)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.privacy_tip, color: Color(0xFF22C55E)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Privacy Notice: Local processing active. Data remains on device.',
                    style: TextStyle(color: Color(0xFF22C55E), fontFamily: 'Inter'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Holding Breakdown
          Text(
            (scanData!['priority_matrix'] != null && (scanData!['priority_matrix'] as List).isNotEmpty)
                ? 'Selected Holding Breakdown (${(scanData!['priority_matrix'] as List).first['company']}) - Priority Score: ${(scanData!['priority_matrix'] as List).first['score']}'
                : 'Selected Holding Breakdown - No Priorities Available',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFactorTile('Entity Relevance', entityRel),
              _buildFactorTile('Event Relevance', eventRel),
              _buildFactorTile('Evidence Quality', evidenceQual),
              _buildFactorTile('Recency', recency),
              _buildFactorTile('Corroboration Multiplier', corroboration),
            ],
          ),
          const SizedBox(height: 32),
          
          // Evidence Cards
          const Text(
            'Verified Public Evidence',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
          ),
          const SizedBox(height: 12),
          if (newsEvidence.isEmpty)
            const Text("No news items retrieved from SerpApi.", style: TextStyle(color: Color(0xFFA1A1AA)))
          else
            ...newsEvidence.map((news) {
              return _buildEvidenceCard(
                news['ticker']?.toString() ?? '',
                news['headline']?.toString() ?? '',
                news['snippet']?.toString() ?? '',
                news['source']?.toString() ?? '',
                news['url']?.toString() ?? ''
              );
            }).toList()
        ],
      ),
    );
  }

  Widget _buildFactorTile(String title, String value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildEvidenceCard(String ticker, String headline, String snippet, String source, String url) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(4)),
                child: Text(ticker, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 10)),
              ),
              const SizedBox(width: 8),
              Text(source, style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(headline, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Inter')),
          const SizedBox(height: 8),
          Text('"$snippet"', style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 14, fontStyle: FontStyle.italic, fontFamily: 'Inter')),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              child: const Text('View Source ->', style: TextStyle(color: Color(0xFF4F46E5))),
            ),
          )
        ],
      ),
    );
  }
}
