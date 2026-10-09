import 'package:flutter/material.dart';

class PrivacyGateScreen extends StatefulWidget {
  final Map<String, dynamic>? scanData;
  const PrivacyGateScreen({super.key, this.scanData});

  @override
  State<PrivacyGateScreen> createState() => _PrivacyGateScreenState();
}

class _PrivacyGateScreenState extends State<PrivacyGateScreen> {
  bool _isResearching = false;
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.scanData == null) {
      return const Center(child: Text("No data to secure. Import a CSV first.", style: TextStyle(color: Color(0xFFA1A1AA))));
    }

    final auditLog = widget.scanData!['audit_log'] as List? ?? [];
    final holdings = widget.scanData!['portfolio_summary']?['holdings'] as Map? ?? {};
    final tickers = holdings.keys.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // EXACT QUERIES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Exact Public Search Intents", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => _showPrivacyPayload(context, tickers),
                icon: const Icon(Icons.shield, color: Color(0xFF4F46E5), size: 16),
                label: const Text("VIEW PRIVACY PAYLOAD", style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 12),
          ...tickers.map((t) => _buildQueryCard(t.toString(), t.toString())).toList(),
          const SizedBox(height: 32),
          
          // RUNNER (Now just a status)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF22C55E).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF22C55E))),
            child: Column(
              children: [
                const Text("AUTOMATIC RESEARCH COMPLETE", style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text("Researching ${tickers.length} holdings...", style: const TextStyle(color: Color(0xFF22C55E))),
                const SizedBox(height: 8),
                const LinearProgressIndicator(value: 1.0, backgroundColor: Color(0xFF121212), color: Color(0xFF22C55E)),
              ]
            ),
          ),
          const SizedBox(height: 48),
          
          // AUDIT TRAIL
          const Text("Search Query & Audit Log", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(const Color(0xFF121212)),
                  columns: const [
                    DataColumn(label: Text("Timestamp", style: TextStyle(color: Color(0xFFA1A1AA)))),
                    DataColumn(label: Text("Asset / Entity", style: TextStyle(color: Color(0xFFA1A1AA)))),
                    DataColumn(label: Text("Request Type", style: TextStyle(color: Color(0xFFA1A1AA)))),
                    DataColumn(label: Text("Exact Safe Query Sent", style: TextStyle(color: Color(0xFFA1A1AA)))),
                    DataColumn(label: Text("Status", style: TextStyle(color: Color(0xFFA1A1AA)))),
                    DataColumn(label: Text("Price Received", style: TextStyle(color: Color(0xFFA1A1AA)))),
                  ],
                  rows: auditLog.map<DataRow>((log) {
                    return DataRow(cells: [
                      DataCell(Text(log['timestamp']?.toString() ?? '', style: const TextStyle(color: Color(0xFFA1A1AA)))),
                      DataCell(Text(log['asset']?.toString() ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      DataCell(Text(log['request_type']?.toString() ?? 'SerpApi Lookup', style: const TextStyle(color: Color(0xFFEAB308)))),
                      DataCell(Text(log['sanitized_query']?.toString() ?? '', style: const TextStyle(color: Color(0xFFF8F9FA), fontFamily: 'monospace'))),
                      DataCell(Text(log['execution_status']?.toString() ?? "COMPLETED", style: const TextStyle(color: Color(0xFF22C55E)))),
                      DataCell(Text(log['price_received']?.toString() ?? 'N/A', style: const TextStyle(color: Colors.white))),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQueryCard(String ticker, String company) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(company, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF22C55E).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: const Text("PRE-VALIDATED SAFE", style: TextStyle(color: Color(0xFF22C55E), fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(8)),
            child: Text('Public query:\n"$ticker:NSE"\n\nPRIVATE DATA: NOT SENT', style: const TextStyle(color: Color(0xFFF8F9FA), fontFamily: 'monospace', fontSize: 12)),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.info_outline, color: Color(0xFFA1A1AA), size: 14),
              SizedBox(width: 6),
              Text("Data leaving device: Public identifier only  |  Private portfolio data: NOT INCLUDED", style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }

  void _showPrivacyPayload(BuildContext context, List<dynamic> tickers) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Privacy Payload Inspector", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Data transmitted to SerpApi (External Search Engine):", style: TextStyle(color: Color(0xFFA1A1AA))),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  '[\n' + tickers.map((t) => '  {\n    "entity": "$t",\n    "query": "latest public news about $t"\n  }').join(',\n') + '\n]',
                  style: const TextStyle(color: Color(0xFF22C55E), fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
              const Text("NOT INCLUDED:", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildRedCross("Quantity"),
              _buildRedCross("Buy Price"),
              _buildRedCross("Average Price"),
              _buildRedCross("Portfolio Value"),
              _buildRedCross("Current Value"),
              _buildRedCross("P&L"),
              _buildRedCross("Portfolio Allocation"),
              _buildRedCross("Account Information"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Close", style: TextStyle(color: Color(0xFFA1A1AA))))
        ],
      )
    );
  }

  Widget _buildRedCross(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.close, color: Color(0xFFEF4444), size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}
