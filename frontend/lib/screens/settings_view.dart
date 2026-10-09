import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  final String aiMode;
  final ValueChanged<String> onAiModeChanged;
  final TextEditingController apiKeyController;

  const SettingsView({
    super.key,
    required this.aiMode,
    required this.onAiModeChanged,
    required this.apiKeyController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Settings", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("AI Provider Selection", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildAiToggle("local", Icons.gpp_good_outlined, "Local AI (Ollama)", aiMode == "local"),
                    const SizedBox(width: 16),
                    _buildAiToggle("cloud", Icons.cloud_outlined, "Cloud AI (Gemini)", aiMode == "cloud"),
                  ],
                ),
                if (aiMode == "cloud") ...[
                  const SizedBox(height: 24),
                  const Text("Gemini API Key", style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 400,
                    child: TextField(
                      controller: apiKeyController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Enter API Key...',
                        hintStyle: const TextStyle(color: Color(0xFFA1A1AA)),
                        filled: true,
                        fillColor: const Color(0xFF121212),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                      ),
                    ),
                  )
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAiToggle(String value, IconData icon, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => onAiModeChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2A2A2A) : const Color(0xFF121212),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFA1A1AA), size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFFA1A1AA), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
