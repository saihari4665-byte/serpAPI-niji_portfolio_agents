import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/api_service.dart';

class ImportProgressDialog extends StatefulWidget {
  final Uint8List fileBytes;
  final String fileName;
  final String? geminiApiKey;
  final ApiService apiService;

  const ImportProgressDialog({
    super.key,
    required this.fileBytes,
    required this.fileName,
    this.geminiApiKey,
    required this.apiService,
  });

  @override
  State<ImportProgressDialog> createState() => _ImportProgressDialogState();
}

class _ImportProgressDialogState extends State<ImportProgressDialog> {
  int _progress = 0;
  String _status = "Initializing...";
  Map<String, dynamic>? _scanData;
  bool _isDone = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startImport();
  }

  Future<void> _startImport() async {
    try {
      setState(() { _progress = 15; _status = "Reading CSV"; });
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() { _progress = 45; _status = "Uploading and parsing portfolio..."; });
      await widget.apiService.uploadPortfolio(widget.fileBytes, widget.fileName);
      
      setState(() { _progress = 60; _status = "Extracting entities & fetching evidence..."; });
      var initialData = await widget.apiService.scanPortfolio();
      
      setState(() { _progress = 85; _status = "Running local AI analysis..."; });
      var finalData = await widget.apiService.analyzePortfolio(
        widget.geminiApiKey != null && widget.geminiApiKey!.isNotEmpty ? "cloud" : "local",
        widget.geminiApiKey
      );
      
      setState(() {
        _progress = 100;
        _status = "Portfolio imported successfully";
        _scanData = finalData;
        _isDone = true;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _status = "Import Failed";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        _error != null ? "IMPORT FAILED" : (_isDone ? "IMPORT COMPLETE" : "IMPORTING PORTFOLIO"),
        style: TextStyle(
          color: _error != null ? const Color(0xFFEF4444) : Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold
        )
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("$_progress%", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progress / 100.0,
                minHeight: 8,
                backgroundColor: const Color(0xFF121212),
                color: _error != null ? const Color(0xFFEF4444) : const Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: TextStyle(
                color: _error != null ? const Color(0xFFEF4444) : const Color(0xFFA1A1AA),
                fontSize: 14
              )
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
            ],
            if (_isDone && _scanData != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2A2A2A))
                ),
                child: Column(
                  children: [
                    _buildSummaryRow("${(_scanData!['portfolio_summary']?['holdings'] as Map?)?.length ?? 0} Holdings"),
                    _buildSummaryRow("₹${(_scanData!['current_value'] as num?)?.toStringAsFixed(2) ?? '0.00'} Current Value"),
                    _buildSummaryRow("₹${(_scanData!['total_invested'] as num?)?.toStringAsFixed(2) ?? '0.00'} Invested"),
                    _buildSummaryRow("${(_scanData!['sector_allocation'] as List?)?.length ?? 0} Sectors"),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
      actions: [
        if (_error != null)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Color(0xFFA1A1AA))),
          ),
        if (_isDone)
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _scanData),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
            child: const Text("View Portfolio"),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 16),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}
