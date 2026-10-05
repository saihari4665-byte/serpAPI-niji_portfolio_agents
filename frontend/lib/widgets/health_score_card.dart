import 'package:flutter/material.dart';

class HealthScoreCard extends StatelessWidget {
  final int score;
  final String label;

  const HealthScoreCard({super.key, required this.score, required this.label});

  Color get scoreColor {
    if (score >= 75) return const Color(0xFF22C55E); // Soft Green
    if (score >= 50) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Soft Red
  }

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Portfolio Health",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFA1A1AA)),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  color: scoreColor,
                  backgroundColor: const Color(0xFF2A2A2A),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "A",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: scoreColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "$score / 100 • $label",
            style: const TextStyle(color: Color(0xFFF8F9FA), fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
