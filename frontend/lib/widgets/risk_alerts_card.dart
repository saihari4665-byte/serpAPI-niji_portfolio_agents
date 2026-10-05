import 'package:flutter/material.dart';

class RiskAlertsCard extends StatelessWidget {
  const RiskAlertsCard({super.key});

  @override
  Widget build(BuildContext context) {
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
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 18),
              SizedBox(width: 8),
              Text("Red Flag Alerts", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFA1A1AA))),
            ],
          ),
          const SizedBox(height: 20),
          _buildAlertRow(
            icon: Icons.pie_chart_outline,
            color: const Color(0xFFF59E0B),
            title: "Sector Concentration Risk",
            description: "High exposure to Financials detected. You might want to consider diversifying.",
          ),
          const SizedBox(height: 16),
          _buildAlertRow(
            icon: Icons.money_off_rounded,
            color: const Color(0xFFEF4444),
            title: "Expense Ratio Flag",
            description: "No mutual funds detected, but keep an eye on your direct stock brokerage fees.",
          ),
          const SizedBox(height: 16),
          _buildAlertRow(
            icon: Icons.content_copy_rounded,
            color: const Color(0xFF22C55E),
            title: "Overlap Check",
            description: "Looks good! No significant direct vs mutual fund overlap detected.",
          ),
        ],
      ),
    );
  }

  Widget _buildAlertRow({required IconData icon, required Color color, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: const Color(0xFFF8F9FA), fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 6),
                Text(description, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
