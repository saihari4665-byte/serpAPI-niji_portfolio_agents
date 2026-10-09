import 'package:flutter/material.dart';

class PrivacyGateDialog extends StatelessWidget {
  final List<String> queries;

  const PrivacyGateDialog({super.key, required this.queries});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.security, color: Color(0xFF22C55E)),
          SizedBox(width: 8),
          Text(
            "Privacy Gate Approval",
            style: TextStyle(color: Color(0xFFF8F9FA), fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Zero financial values, quantities, or P&L data will leave this device. Only the following generic queries will be executed:",
              style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: queries.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      queries[index],
                      style: const TextStyle(color: Color(0xFFF8F9FA), fontSize: 13, fontFamily: 'monospace'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel", style: TextStyle(color: Color(0xFFA1A1AA))),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: const Text("Approve & Start AI"),
        ),
      ],
    );
  }
}
