import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shimmer/shimmer.dart';

class AiBriefingPanel extends StatelessWidget {
  final bool isAnalyzing;
  final String? markdownContent;
  final bool scanDataAvailable;

  const AiBriefingPanel({
    super.key,
    required this.isAnalyzing,
    required this.markdownContent,
    required this.scanDataAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(left: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology_outlined, color: Color(0xFF4F46E5), size: 24),
                const SizedBox(width: 12),
                const Text("Gemma AI Analyst", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFF8F9FA))),
                const Spacer(),
                if (isAnalyzing)
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4F46E5))),
              ],
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
          if (markdownContent != null && !isAnalyzing)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChip("Explain High Beta"),
                    const SizedBox(width: 12),
                    _buildChip("Suggest Rebalancing"),
                    const SizedBox(width: 12),
                    _buildChip("Stress Test Market Crash"),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isAnalyzing) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Shimmer.fromColors(
          baseColor: const Color(0xFF2A2A2A),
          highlightColor: const Color(0xFF3F3F46),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSkeleton(width: 200, height: 24),
              const SizedBox(height: 24),
              _buildSkeleton(width: double.infinity, height: 14),
              const SizedBox(height: 8),
              _buildSkeleton(width: double.infinity, height: 14),
              const SizedBox(height: 8),
              _buildSkeleton(width: 250, height: 14),
              const SizedBox(height: 32),
              _buildSkeleton(width: 150, height: 20),
              const SizedBox(height: 16),
              _buildSkeleton(width: double.infinity, height: 14),
              const SizedBox(height: 8),
              _buildSkeleton(width: double.infinity, height: 14),
              const SizedBox(height: 8),
              _buildSkeleton(width: double.infinity, height: 14),
            ],
          ),
        ),
      );
    }
    
    if (markdownContent != null) {
      return Markdown(
        padding: const EdgeInsets.all(24),
        data: markdownContent!,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(color: Color(0xFFF8F9FA), fontSize: 14, height: 1.6),
          h1: const TextStyle(color: Color(0xFFF8F9FA), fontSize: 24, fontWeight: FontWeight.w600),
          h2: const TextStyle(color: Color(0xFFF8F9FA), fontSize: 18, fontWeight: FontWeight.w600),
          h3: const TextStyle(color: Color(0xFFF8F9FA), fontSize: 16, fontWeight: FontWeight.w600),
          listBullet: const TextStyle(color: Color(0xFFA1A1AA)),
          strong: const TextStyle(color: Color(0xFFF8F9FA), fontWeight: FontWeight.w700),
          blockquote: const TextStyle(color: Color(0xFFA1A1AA), fontStyle: FontStyle.italic, height: 1.6),
          blockquoteDecoration: BoxDecoration(
            border: const Border(left: BorderSide(color: Color(0xFF4F46E5), width: 3)),
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(4),
          ),
          code: const TextStyle(backgroundColor: Color(0xFF121212), fontFamily: 'monospace', color: Color(0xFFF8F9FA)),
          codeblockDecoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
        ),
      );
    }

    if (!scanDataAvailable) {
      return const Center(
        child: Text("Waiting for portfolio data...", style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14)),
      );
    }

    return const Center(
      child: Text("Analysis ready to begin.", style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14)),
    );
  }

  Widget _buildSkeleton({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  Widget _buildChip(String label) {
    return ActionChip(
      label: Text(label, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, fontWeight: FontWeight.w500)),
      backgroundColor: Colors.transparent,
      side: const BorderSide(color: Color(0xFF2A2A2A)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onPressed: () {},
    );
  }
}
