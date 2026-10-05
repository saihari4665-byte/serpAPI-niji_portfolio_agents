import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QuickStatsCard extends StatelessWidget {
  final Map<String, dynamic> scanData;

  const QuickStatsCard({super.key, required this.scanData});

  @override
  Widget build(BuildContext context) {
    final portfolioSummary = scanData['portfolio_summary'] ?? {};
    final marketData = scanData['market_data'] ?? {};
    
    double totalInvested = portfolioSummary['total_value'] ?? 0.0;
    
    double currentValue = 0.0;
    final holdings = portfolioSummary['holdings'] ?? {};
    
    holdings.forEach((ticker, data) {
      final shares = data['shares'] ?? 0;
      final mData = marketData[ticker]?['price'];
      if (mData != null && mData['current_price'] != null) {
        String priceStr = mData['current_price'].toString().replaceAll(',', '');
        double price = double.tryParse(priceStr) ?? 0.0;
        currentValue += shares * price;
      } else {
        currentValue += (data['avg_buy_price'] ?? 0.0) * shares;
      }
    });

    double pnl = currentValue - totalInvested;
    double pnlPct = totalInvested > 0 ? (pnl / totalInvested) * 100 : 0.0;
    
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final isPositive = pnl >= 0;
    final pnlColor = isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final pnlIcon = isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Quick Stats", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFA1A1AA))),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCol("Total Invested", currency.format(totalInvested), const Color(0xFFF8F9FA)),
              _buildStatCol("Current Value", currency.format(currentValue), const Color(0xFFF8F9FA)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("1D P&L", style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: pnlColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(pnlIcon, color: pnlColor, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(currency.format(pnl.abs()), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: pnlColor)),
                          const SizedBox(height: 2),
                          Text("${isPositive ? '+' : '-'}${pnlPct.abs().toStringAsFixed(2)}%", style: TextStyle(color: pnlColor, fontWeight: FontWeight.w500, fontSize: 13)),
                        ],
                      )
                    ],
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: valueColor)),
      ],
    );
  }
}
