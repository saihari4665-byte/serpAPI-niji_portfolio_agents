import 'package:flutter/material.dart';

class PortfolioView extends StatefulWidget {
  final Map<String, dynamic>? scanData;
  final VoidCallback onUploadPressed;
  
  const PortfolioView({super.key, this.scanData, required this.onUploadPressed});
  
  @override
  State<PortfolioView> createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    if (widget.scanData == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("No portfolio data available.", style: TextStyle(color: Color(0xFFA1A1AA))),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: widget.onUploadPressed,
              icon: const Icon(Icons.upload_file),
              label: const Text("Import CSV"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
            )
          ],
        ),
      );
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
              const Text("My Portfolio", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search ticker...',
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
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: widget.onUploadPressed,
                    icon: const Icon(Icons.upload_file, size: 16),
                    label: const Text("Import CSV"),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  )
                ],
              )
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
                      DataColumn(label: Text("Stock Name", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Ticker", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Sector", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Qty", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Buy", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Current", style: TextStyle(color: Color(0xFFA1A1AA)))),
                    ],
                    rows: filtered.map((item) {
                      double qty = item['shares']?.toDouble() ?? 0.0;
                      double avgBuy = item['avg_buy_price']?.toDouble() ?? 0.0;
                      double currentVal = item['current_value']?.toDouble() ?? 0.0;
                      double curPrice = qty > 0 ? currentVal / qty : 0.0;

                      return DataRow(cells: [
                        DataCell(Text(item['ticker'].toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), // Reusing ticker as name for now as we don't fetch full name
                        DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(4)), child: Text(item['ticker'].toString(), style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)))),
                        DataCell(Text(item['sector'].toString(), style: const TextStyle(color: Color(0xFFA1A1AA)))),
                        DataCell(Text(qty.toStringAsFixed(2), style: const TextStyle(color: Colors.white))),
                        DataCell(Text('₹${avgBuy.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white))),
                        DataCell(Text('₹${curPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white))),
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
