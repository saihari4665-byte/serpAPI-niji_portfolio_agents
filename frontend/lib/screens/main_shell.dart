import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../widgets/import_csv_dialog.dart';
import '../widgets/import_progress_dialog.dart';
import 'dashboard_screen.dart';
import 'portfolio_screen.dart';
import 'privacy_gate_screen.dart';
import 'reports_screen.dart';
import 'evidence_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final ApiService _apiService = ApiService();
  int _selectedIndex = 0;
  bool _isAirGapped = true;
  Map<String, dynamic>? _scanData;
  String? _savedGeminiKey;
  
  final List<String> _breadcrumbs = [
    "Dashboard",
    "My Portfolio",
    "Privacy Gate",
    "Reports",
    "Evidence Explorer"
  ];

  Future<void> _showImportModal([String? geminiApiKey]) async {
    debugPrint("Upload triggered with key: $geminiApiKey");
    if (geminiApiKey != null && geminiApiKey.isNotEmpty) {
      _savedGeminiKey = geminiApiKey;
      _isAirGapped = false;
    }
    
    try {
      PlatformFile? file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['csv']);
      debugPrint("File picked: ${file?.name}");
      if (file == null) return;
      var bytes = await file.readAsBytes();
      debugPrint("Bytes read: ${bytes.length}");
      var scanData = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (c) => ImportProgressDialog(
          fileBytes: bytes,
          fileName: file.name,
          geminiApiKey: _savedGeminiKey,
          apiService: _apiService,
        )
      );

      if (scanData != null && mounted) {
        setState(() {
          _scanData = scanData;
          _selectedIndex = 0; // Jump to Dashboard to see the new charts
        });
        
        int debugHoldings = (_scanData!['holdings'] as List?)?.length ?? 0;
        double debugInvested = _scanData!['total_invested']?.toDouble() ?? 0.0;
        double debugCurrent = _scanData!['current_value']?.toDouble() ?? 0.0;
        double debugPnl = _scanData!['pnl']?.toDouble() ?? 0.0;
        int debugSectors = (_scanData!['sector_allocation'] as List?)?.length ?? 0;
        int debugPriorities = (_scanData!['priority_matrix'] as List?)?.length ?? 0;
        
        debugPrint("\n====================================");
        debugPrint("Portfolio State:");
        debugPrint("Holdings: $debugHoldings");
        debugPrint("Invested: ₹$debugInvested");
        debugPrint("Current: ₹$debugCurrent");
        debugPrint("P&L: ₹$debugPnl");
        debugPrint("Sectors: $debugSectors");
        debugPrint("Research Priorities: $debugPriorities");
        debugPrint("====================================\n");
      }
    } catch (e) {
      debugPrint("Upload failed: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  void _refreshPrices() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text("Refreshing Market Data", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(color: Color(0xFF4F46E5)),
              SizedBox(height: 16),
              Text("Fetching live prices from SerpApi Google Finance...", style: TextStyle(color: Color(0xFFA1A1AA))),
            ],
          ),
        ),
      );

      String aiMode = (_savedGeminiKey != null && _savedGeminiKey!.isNotEmpty) ? "cloud" : "local";
      final newData = await _apiService.analyzePortfolio(aiMode, _savedGeminiKey, forceRefresh: true);
      if (mounted) {
        Navigator.of(context).pop(); // dismiss dialog
        setState(() {
          _scanData = newData;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Market prices updated!'), backgroundColor: Color(0xFF22C55E)));
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Refresh failed: $e'), backgroundColor: const Color(0xFFEF4444)));
      }
    }
  }

  Widget _buildNavItem(IconData icon, String label, int index, {bool hasBadge = false}) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFA1A1AA), size: 20),
        title: Row(
          children: [
            Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFFA1A1AA), fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
            if (hasBadge) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF22C55E).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: const Text("Active", style: TextStyle(color: Color(0xFF22C55E), fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ]
          ],
        ),
        selected: isSelected,
        selectedTileColor: const Color(0xFF4F46E5).withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        dense: true,
        onTap: () => setState(() => _selectedIndex = index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Row(
        children: [
          // SIDEBAR (230px)
          Container(
            width: 230,
            color: const Color(0xFF161616),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BRAND HEADER
                Image.asset(
                  'assets/images/niji_logo.png',
                  width: 64, // Made slightly larger since it's the only element now, adjust if needed
                  height: 48,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                
                // NAV ITEMS
                _buildNavItem(Icons.dashboard_outlined, "Dashboard", 0),
                _buildNavItem(Icons.table_chart_outlined, "My Portfolio", 1),
                _buildNavItem(Icons.security_outlined, "Privacy Gate", 2, hasBadge: true),
                _buildNavItem(Icons.description_outlined, "Reports", 3, hasBadge: true),
                _buildNavItem(Icons.travel_explore_outlined, "Evidence Explorer", 4),
                
                const Spacer(),
                

              ],
            ),
          ),
          
          // MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [
                // TOP APP BAR
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF121212),
                    border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
                  ),
                  child: Row(
                    children: [
                      // Breadcrumbs & Version
                      Text(_breadcrumbs[_selectedIndex], style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 14, fontWeight: FontWeight.bold)),

                      const Spacer(),
                      // Top Right Status & Actions
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: _isAirGapped ? const Color(0xFF22C55E).withOpacity(0.1) : const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Icon(Icons.circle, color: _isAirGapped ? const Color(0xFF22C55E) : const Color(0xFFF59E0B), size: 8),
                            const SizedBox(width: 8),
                            Text(_isAirGapped ? "Local Air-Gapped Mode" : "Cloud Connection Active", style: TextStyle(color: _isAirGapped ? const Color(0xFF22C55E) : const Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showImportModal(),
                        icon: const Icon(Icons.upload_file, size: 16),
                        label: const Text("Import CSV"),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      )
                    ],
                  ),
                ),
                
                // TAB VIEWS
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      DashboardScreen(
                        scanData: _scanData,
                        onUploadPressed: (key) => _showImportModal(key),
                        onViewReportPressed: () => setState(() => _selectedIndex = 3),
                        onRefreshPressed: () => _refreshPrices(),
                      ),
                      PortfolioScreen(
                        scanData: _scanData, 
                        onUploadPressed: () => _showImportModal(),
                        onRefreshPressed: () => _refreshPrices()
                      ),
                      PrivacyGateScreen(scanData: _scanData),
                      ReportsScreen(scanData: _scanData),
                      EvidenceScreen(scanData: _scanData),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
