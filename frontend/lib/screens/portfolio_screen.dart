import 'package:flutter/material.dart';

class PortfolioScreen extends StatelessWidget {
  final Map<String, dynamic>? scanData;
  final VoidCallback onUploadPressed;
  final VoidCallback onRefreshPressed;

  const PortfolioScreen({super.key, required this.scanData, required this.onUploadPressed, required this.onRefreshPressed});

  @override
  Widget build(BuildContext context) {
    if (scanData == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("No Holdings Registered Yet.", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("Your local portfolio database is currently empty. Import your positions via CSV to begin.", style: TextStyle(color: Color(0xFFA1A1AA))),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onUploadPressed,
              icon: const Icon(Icons.upload_file),
              label: const Text("Import CSV File"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    }

    final list = scanData!['holdings'] as List? ?? [];

    double totalInvested = (scanData!['total_invested'] as num?)?.toDouble() ?? 0.0;
    double currentValue = (scanData!['current_value'] as num?)?.toDouble() ?? 0.0;
    double pnl = (scanData!['pnl'] as num?)?.toDouble() ?? 0.0;
    double pnlPct = (scanData!['pnl_percentage'] as num?)?.toDouble() ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // STATS ROW & BUTTONS
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _buildStatCard("Total Investment", "₹${totalInvested.toStringAsFixed(2)}"),
                  _buildStatCard("Total Holdings Value", "₹${currentValue.toStringAsFixed(2)}"),
                  _buildStatCard("Unrealized Gain / Loss", "${pnl >= 0 ? '+' : ''}₹${pnl.abs().toStringAsFixed(2)} / ${pnlPct >= 0 ? '+' : ''}${pnlPct.toStringAsFixed(2)}%", isPositive: pnl >= 0),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: onRefreshPressed,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text("Refresh Prices"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2A2A), 
                      foregroundColor: Colors.white, 
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: onUploadPressed,
                    icon: const Icon(Icons.upload_file, size: 16),
                    label: const Text("Import CSV"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5), 
                      foregroundColor: Colors.white, 
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
                    ),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // MARKET DATA STATUS
          if (scanData!['prices_updated'] != null)
            Row(
              children: [
                Icon(Icons.circle, size: 8, color: scanData!['prices_updated'] == scanData!['total_tickers'] ? const Color(0xFF22C55E) : const Color(0xFFEAB308)),
                const SizedBox(width: 8),
                Text(
                  "MARKET DATA • ${scanData!['prices_updated']}/${scanData!['total_tickers']} prices updated via SerpApi Google Finance", 
                  style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)
                ),
              ],
            ),
          const SizedBox(height: 24),
          
          // DATA TABLE
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 1000),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFF121212)),
                    columns: const [
                      DataColumn(label: Text("Stock Name", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Ticker", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Sector", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Qty", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Buy Price (₹)", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Current Price (₹)", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Invested Value (₹)", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Current Value (₹)", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("P&L (₹)", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("P&L %", style: TextStyle(color: Color(0xFFA1A1AA)))),
                      DataColumn(label: Text("Status", style: TextStyle(color: Color(0xFFA1A1AA)))),
                    ],
                    rows: list.map<DataRow>((item) {
                      double qty = item['quantity']?.toDouble() ?? item['shares']?.toDouble() ?? 0.0;
                      double avgBuy = item['buy_price']?.toDouble() ?? item['avg_buy_price']?.toDouble() ?? 0.0;
                      double curPrice = item['current_price']?.toDouble() ?? 0.0;
                      double investedValue = item['invested_value']?.toDouble() ?? item['investment_value']?.toDouble() ?? 0.0;
                      double currentVal = item['current_value']?.toDouble() ?? 0.0;
                      double itemPnl = item['pnl']?.toDouble() ?? 0.0;
                      double itemPnlPct = item['pnl_percent']?.toDouble() ?? 0.0;
                      bool isStale = item['price_stale'] == true;
                      
                      return _buildMockRow(
                        item['stock_name']?.toString() ?? item['ticker']?.toString() ?? 'Unknown', 
                        item['ticker']?.toString() ?? 'Unknown', 
                        item['sector']?.toString() ?? 'Unknown', 
                        qty, avgBuy, curPrice, investedValue, currentVal, itemPnl, itemPnlPct, isStale
                      );
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

  Widget _buildStatCard(String title, String value, {bool? isPositive}) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isPositive == null ? Colors.white : (isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444)),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildMockRow(String name, String ticker, String sector, double qty, double buy, double cur, double investedValue, double currentVal, double pnl, double pnlPct, bool isStale) {
    return DataRow(
      cells: [
        DataCell(Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(4)),
          child: Text(ticker, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
        )),
        DataCell(Text(sector, style: const TextStyle(color: Color(0xFFA1A1AA)))),
        DataCell(Text(qty.toStringAsFixed(0), style: const TextStyle(color: Colors.white))),
        DataCell(Text('₹${buy.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white))),
        DataCell(Text('₹${cur.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white))),
        DataCell(Text('₹${investedValue.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white))),
        DataCell(Text('₹${currentVal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white))),
        DataCell(Text(
          '${pnl >= 0 ? '+' : ''}₹${pnl.abs().toStringAsFixed(2)}',
          style: TextStyle(color: pnl >= 0 ? const Color(0xFF22C55E) : const Color(0xFFEF4444), fontWeight: FontWeight.bold),
        )),
        DataCell(Text(
          '${pnlPct >= 0 ? '+' : ''}${pnlPct.toStringAsFixed(2)}%',
          style: TextStyle(color: pnlPct >= 0 ? const Color(0xFF22C55E) : const Color(0xFFEF4444), fontWeight: FontWeight.bold),
        )),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: isStale ? const Color(0xFFEAB308) : const Color(0xFF22C55E)),
              const SizedBox(width: 6),
              Text(isStale ? "Stale" : "Live", style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
            ],
          )
        ),
      ],
    );
  }
}
