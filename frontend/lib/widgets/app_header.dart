import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onUploadPressed;
  final String aiMode;
  final ValueChanged<String> onAiModeChanged;
  final TextEditingController apiKeyController;

  const AppHeader({
    super.key, 
    required this.onUploadPressed,
    required this.aiMode,
    required this.onAiModeChanged,
    required this.apiKeyController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF4F46E5), size: 24),
              ),
              const SizedBox(width: 16),
              const Text(
                'Niji Portfolio Agent',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF8F9FA),
                ),
              ),
              const SizedBox(width: 24),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Row(
                  children: [
                    _buildAiToggle("local", Icons.gpp_good_outlined, "Local AI", aiMode == "local"),
                    _buildAiToggle("cloud", Icons.cloud_outlined, "Gemini", aiMode == "cloud"),
                  ],
                ),
              ),
              if (aiMode == "cloud") ...[
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 36,
                      child: TextField(
                        controller: apiKeyController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Gemini API Key',
                          hintStyle: const TextStyle(color: Color(0xFFA1A1AA)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          filled: true,
                          fillColor: const Color(0xFF1E1E1E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF4F46E5)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text("⚠️ Cloud testing only.", style: TextStyle(color: Color(0xFFF59E0B), fontSize: 10)),
                  ],
                ),
              ],
            ],
          ),
          ElevatedButton.icon(
            onPressed: onUploadPressed,
            icon: const Icon(Icons.cloud_upload_outlined, size: 18),
            label: const Text("Upload CSV"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiToggle(String value, IconData icon, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => onAiModeChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2A2A2A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? (value == "local" ? const Color(0xFF22C55E) : const Color(0xFF0EA5E9)) : const Color(0xFFA1A1AA), size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFF8F9FA) : const Color(0xFFA1A1AA),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
