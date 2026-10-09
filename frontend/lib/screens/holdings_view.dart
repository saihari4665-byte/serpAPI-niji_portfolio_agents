import 'package:flutter/material.dart';

class HoldingsView extends StatefulWidget {
  final Map<String, dynamic>? scanData;
  const HoldingsView({super.key, this.scanData});
  @override
  State<HoldingsView> createState() => _HoldingsViewState();
}
class _HoldingsViewState extends State<HoldingsView> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    if (widget.scanData == null) {
      return const Center(child: Text("No holdings data available.", style: TextStyle(color: Color(0xFFA1A1AA))));
    }

    final holdings = widget.scanData!['portfolio_summary']?['holdings'] ?? {};
    final list = holdings.entries.map((e) => {"ticker": e.key, ...e.value}).toList();
    final filtered = list.where((item) => (item['ticker'] as String).toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Portfolio Holdings", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(
                width: 300,
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search instrument...',
                    hintStyle: const TextStyle(color: Color(0xFFA1A1AA)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFA1A1AA), size: 18),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(const Color(0xFF121212)),
                    columns: const [
                      DataColumn(label: Text("Instrument", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Sector", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Quantity", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Avg. Buy (₹)", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Cur. Price (₹)", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("P&L (₹)", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Net P&L (%)", style: TextStyle(color: Color(0xFFA1A1AA)))),
                    ],
                    rows: filtered.map((item) {
                      double qty = item['shares']?.toDouble() ?? 0.0;
                      double avgBuy = item['avg_buy_price']?.toDouble() ?? 0.0;
                      double currentVal = item['current_value']?.toDouble() ?? 0.0;
                      double curPrice = qty > 0 ? currentVal / qty : 0.0;
                      double pnl = currentVal - (qty * avgBuy);
                      double pnlPct = qty * avgBuy > 0 ? (pnl / (qty * avgBuy)) * 100 : 0.0;
                      
                      Color pnlColor = pnl >= 0 ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

                      return DataRow(cells: [
                        DataCell(Text(item['ticker'].toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataCell(Text(item['sector'].toString(), style: const TextStyle(color: Color(0xFFA1A1AA)))),
                        DataCell(Text(qty.toStringAsFixed(2), style: const TextStyle(color: Colors.white))),
                        DataCell(Text(avgBuy.toStringAsFixed(2), style: const TextStyle(color: Colors.white))),
                        DataCell(Text(curPrice.toStringAsFixed(2), style: const TextStyle(color: Colors.white))),
                        DataCell(Text(pnl.toStringAsFixed(2), style: TextStyle(color: pnlColor, fontWeight: FontWeight.bold))),
                        DataCell(Text('${pnlPct.toStringAsFixed(2)}%', style: TextStyle(color: pnlColor))),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
