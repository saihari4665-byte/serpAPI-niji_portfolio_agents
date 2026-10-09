import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class ImportCsvDialog extends StatefulWidget {
  final Future<void> Function(Uint8List, String) onConfirm;
  const ImportCsvDialog({super.key, required this.onConfirm});

  @override
  State<ImportCsvDialog> createState() => _ImportCsvDialogState();
}

class _ImportCsvDialogState extends State<ImportCsvDialog> {
  bool _isParsed = false;
  bool _isImporting = false;
  bool _isPicking = false;
  
  Uint8List? _fileBytes;
  String? _fileName;
  List<dynamic> _previewRows = [];
  int _rowCount = 0;

  Future<void> _pickAndPreview() async {
    setState(() => _isPicking = true);
    try {
      PlatformFile? file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['csv']);
      if (file == null) {
        setState(() => _isPicking = false);
        return;
      }
      var bytes = await file.readAsBytes();
      
      var uri = Uri.parse('http://127.0.0.1:8000/api/portfolio/preview');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: file.name));
      
      var response = await request.send();
      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        var data = jsonDecode(respStr);
        setState(() {
          _fileBytes = bytes;
          _fileName = file.name;
          _rowCount = data['row_count'] ?? 0;
          _previewRows = data['preview_rows'] ?? [];
          _isParsed = true;
        });
      }
    } catch (e) {
      debugPrint("Preview error: $e");
    } finally {
      setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Import Portfolio CSV", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 700,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isParsed) ...[
              GestureDetector(
                onTap: _isPicking ? null : _pickAndPreview,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4F46E5), width: 2, style: BorderStyle.solid),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isPicking)
                          const CircularProgressIndicator(color: Color(0xFF4F46E5))
                        else ...[
                          const Icon(Icons.upload_file, color: Color(0xFF4F46E5), size: 40),
                          const SizedBox(height: 16),
                          const Text("Click to browse for CSV", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF22C55E).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 16),
                    const SizedBox(width: 8),
                    Text("File validated successfully! Found $_rowCount rows", style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text("Data Preview", style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF2A2A2A))),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(const Color(0xFF161616)),
                  columns: const [
                    DataColumn(label: Text("Ticker", style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12))),
                    DataColumn(label: Text("Sector", style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12))),
                    DataColumn(label: Text("Qty", style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12))),
                  ],
                  rows: _previewRows.take(5).map<DataRow>((row) {
                    return DataRow(cells: [
                      DataCell(Text(row['instrument']?.toString() ?? row['symbol']?.toString() ?? row['ticker']?.toString() ?? '-', style: const TextStyle(color: Colors.white, fontSize: 12))),
                      DataCell(Text(row['sector']?.toString() ?? '-', style: const TextStyle(color: Colors.white, fontSize: 12))),
                      DataCell(Text(row['qty']?.toString() ?? row['quantity']?.toString() ?? '0', style: const TextStyle(color: Colors.white, fontSize: 12))),
                    ]);
                  }).toList(),
                ),
              )
            ]
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Color(0xFFA1A1AA))),
        ),
        ElevatedButton(
          onPressed: _isParsed && !_isImporting ? () async {
            setState(() => _isImporting = true);
            await widget.onConfirm(_fileBytes!, _fileName!);
            if (mounted) Navigator.pop(context);
          } : null,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
          child: _isImporting 
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("Confirm Import"),
        ),
      ],
    );
  }
}
