import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? scanData;
  final VoidCallback onUploadPressed;
  final VoidCallback onViewReportPressed;
  final VoidCallback onRefreshPressed;

  final bool isRegenerating; final VoidCallback? onRegenerate; const DashboardScreen({super.key, required this.scanData, required this.onUploadPressed, required this.onViewReportPressed, required this.onRefreshPressed, this.isRegenerating = false, this.onRegenerate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _obscureKey = true;
  int _touchedIndex = -1;



  Widget _buildSectorTooltip(Map sectorData, List holdings, double totalValue) {
    String sectorName = sectorData['sector'];
    double sectorCurrentValue = 0.0;
    List<Map> sectorHoldings = [];
    
    for (var h in holdings) {
      if (h['sector'] == sectorName) {
        double hValue = (h['current_value'] as num?)?.toDouble() ?? 0.0;
        sectorCurrentValue += hValue;
        sectorHoldings.add({
          'ticker': h['ticker'],
          'value': hValue,
        });
      }
    }
    
    sectorHoldings.sort((a, b) => b['value'].compareTo(a['value']));
    double sectorPercentage = totalValue > 0 ? (sectorCurrentValue / totalValue * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sectorName.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text("${sectorPercentage.toStringAsFixed(1)}% of portfolio", style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
          const SizedBox(height: 12),
          const Text("Holdings", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: sectorHoldings.length,
              itemBuilder: (context, idx) {
                final h = sectorHoldings[idx];
                double hVal = h['value'];
                double pctOfSector = sectorCurrentValue > 0 ? (hVal / sectorCurrentValue * 100) : 0.0;
                double pctOfPortfolio = totalValue > 0 ? (hVal / totalValue * 100) : 0.0;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ", style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h['ticker'], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text("${pctOfSector.toStringAsFixed(1)}% of sector", style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 11)),
                            Text("${pctOfPortfolio.toStringAsFixed(1)}% portfolio", style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text("Sector Value: ₹${sectorCurrentValue.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF22C55E), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scanData == null) {
      return Center(
        child: Container(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("No Holdings Registered Yet.", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text("Your local portfolio database is currently empty. Import your positions via CSV to begin.", style: TextStyle(color: Color(0xFFA1A1AA)), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              
              // API KEY FIELD
              
              
              ElevatedButton.icon(
                onPressed: widget.onUploadPressed,
                icon: const Icon(Icons.upload_file),
                label: const Text("Import CSV File"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      );
    }
    
    double totalInvested = (widget.scanData!['total_invested'] as num?)?.toDouble() ?? 0.0;
    double currentValue = (widget.scanData!['current_value'] as num?)?.toDouble() ?? 0.0;
    double pnl = (widget.scanData!['pnl'] as num?)?.toDouble() ?? 0.0;
    double pnlPct = (widget.scanData!['pnl_percentage'] as num?)?.toDouble() ?? 0.0;
    num healthScore = widget.scanData!['health_score'] as num? ?? 0;
    String healthGrade = widget.scanData!['health_grade'] ?? "N/A";
    
    int numHoldings = (widget.scanData!['holdings'] as List?)?.length ?? 0;
    List sectorAllocation = widget.scanData!['sector_allocation'] as List? ?? [];
    int numSectors = sectorAllocation.length;
    List priorities = widget.scanData!['priority_matrix'] as List? ?? [];
    
    // AI Summary logic
    Map aiReport = widget.scanData!['ai_report'] as Map? ?? {};
    bool hasAi = aiReport.isNotEmpty;

    final colors = [
      const Color(0xFF536dfe), // Indigo
      const Color(0xFF00e5ff), // Cyan
      const Color(0xFFff9100), // Orange
      const Color(0xFF00e676), // Emerald
      const Color(0xFFd500f9), // Purple
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TOP OVERVIEW METRICS
          Row(
            children: [
              Expanded(child: _buildMetricCard("Total Market Value", "₹${currentValue.toStringAsFixed(2)}", "Local CSV - An unpegged valuation", const Color(0xFF4F46E5))),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard("Total Invested Capital", "₹${totalInvested.toStringAsFixed(2)}", "Across $numHoldings holdings", const Color(0xFFA1A1AA))),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard("Unrealized P/L", "${pnl >= 0 ? '+' : ''}₹${pnl.toStringAsFixed(2)}", "${pnlPct >= 0 ? '+' : ''}${pnlPct.toStringAsFixed(2)}%", pnl >= 0 ? const Color(0xFF22C55E) : const Color(0xFFEF4444))),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard("Holdings & Sectors", "$numHoldings Holdings", "$numSectors sectors represented", const Color(0xFFA1A1AA))),
            ],
          ),
          const SizedBox(height: 24),
          
          // MIDDLE SECTION
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT: Allocation
              Expanded(
                flex: 4,
                child: Container(
                  height: 340,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Portfolio Allocation", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("${sectorAllocation.length} sectors", style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: sectorAllocation.isEmpty
                          ? const Center(child: Text("No Sector Data", style: TextStyle(color: Color(0xFFA1A1AA))))
                          : Row(
                              children: [
                                // LEFT: Pie Chart
                                Expanded(
                                  flex: 1,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      PieChart(
                                        PieChartData(
                                          pieTouchData: PieTouchData(
                                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                              setState(() {
                                                if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                                                  _touchedIndex = -1;
                                                  return;
                                                }
                                                _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                              });
                                            },
                                          ),
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 70,
                                          sections: sectorAllocation.asMap().entries.map((e) {
                                            final i = e.key;
                                            final s = e.value;
                                            final isTouched = i == _touchedIndex;
                                            final radius = isTouched ? 30.0 : 25.0;
                                            return PieChartSectionData(
                                              color: colors[i % colors.length],
                                              value: (s['percentage'] as num).toDouble(),
                                              title: '',
                                              radius: radius,
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      // Central Text
                                      if (_touchedIndex != -1)
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(sectorAllocation[_touchedIndex]['sector'], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                            Text("${sectorAllocation[_touchedIndex]['percentage']}%", style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 15, fontWeight: FontWeight.bold)),
                                          ],
                                        )
                                      else
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(sectorAllocation.isNotEmpty ? sectorAllocation[0]['sector'] : "", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                            Text("${sectorAllocation.isNotEmpty ? sectorAllocation[0]['percentage'] : ""}%", style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 15, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                // RIGHT: Legend or Tooltip
                                Expanded(
                                  flex: 1,
                                  child: _touchedIndex != -1 
                                    ? _buildSectorTooltip(sectorAllocation[_touchedIndex], widget.scanData!['holdings'] as List? ?? [], currentValue)
                                    : SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: sectorAllocation.asMap().entries.map((e) {
                                            final i = e.key;
                                            final s = e.value;
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 12),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.circle, color: colors[i % colors.length], size: 10),
                                                  const SizedBox(width: 8),
                                                  Expanded(child: Text(s['sector'], style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13))),
                                                  Text("${s['percentage']}%", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                )
                              ],
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // RIGHT: Intelligence Summary
              Expanded(
                flex: 6,
                child: Container(
                  height: 340,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.5))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.auto_awesome, color: Color(0xFF4F46E5)),
                          SizedBox(width: 8),
                          Text("Portfolio Intelligence Summary", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Expanded(
                        child: (!hasAi) 
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
                                const SizedBox(height: 16),
                                const Text("Portfolio analysis unavailable", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                const Text("Reason:\nLocal AI service is unavailable or JSON parsing failed.", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13)),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: widget.onRefreshPressed,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text("Retry Analysis"),
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A2A2A), foregroundColor: Colors.white),
                                )
                              ],
                            )
                          : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(aiReport['executive_assessment']?.toString() ?? "AI Analysis complete.", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  const Text("STRENGTHS:", style: TextStyle(color: Color(0xFF22C55E), fontSize: 12, fontWeight: FontWeight.bold)),
                                  ...(aiReport['strengths'] as List? ?? []).take(3).map((s) => Text("• $s", style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13))),
                                  const SizedBox(height: 8),
                                  const Text("CONCERNS:", style: TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold)),
                                  ...(aiReport['concerns'] as List? ?? []).take(3).map((s) => Text("• $s", style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13))),
                                  const SizedBox(height: 8),
                                  const Text("KEY RISKS & ACTIONS:", style: TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.bold)),
                                  ...(aiReport['investor_questions'] as List? ?? []).take(3).map((s) => Text("• $s", style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13))),
                                ],
                              ),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(onPressed: widget.onViewReportPressed, child: const Text("View Full Report ->", style: TextStyle(color: Color(0xFF4F46E5)))),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          
          // LOWER SECTION
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Top Research Priorities", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      priorities.isEmpty ? const Text("No research priorities.", style: TextStyle(color: Color(0xFFA1A1AA))) : DataTable(
                        headingRowColor: MaterialStateProperty.all(const Color(0xFF121212)),
                        columns: const [
                          DataColumn(label: Text("Company", style: TextStyle(color: Color(0xFFA1A1AA)))),
                          DataColumn(label: Text("Score", style: TextStyle(color: Color(0xFFA1A1AA)))),
                          DataColumn(label: Text("Level", style: TextStyle(color: Color(0xFFA1A1AA)))),
                          DataColumn(label: Text("Direction", style: TextStyle(color: Color(0xFFA1A1AA)))),
                          DataColumn(label: Text("Action", style: TextStyle(color: Color(0xFFA1A1AA)))),
                        ],
                        rows: priorities.map<DataRow>((p) {
                          final isHigh = p['level'] == 'High';
                          final color = isHigh ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
                          return DataRow(cells: [
                            DataCell(Text(p['company'].toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            DataCell(Text(p['score'].toString(), style: const TextStyle(color: Colors.white))),
                            DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(p['level'].toString(), style: TextStyle(color: color, fontSize: 12)))),
                            DataCell(Text(p['direction'].toString(), style: TextStyle(color: color))),
                            const DataCell(Text("Inspect ->", style: TextStyle(color: Color(0xFF4F46E5)))),
                          ]);
                        }).toList(),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
                      child: Column(
                        children: [
                          const Text("Portfolio Health", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          Center(child: Text("$healthScore / 100 • $healthGrade", style: TextStyle(color: healthScore >= 85 ? const Color(0xFF22C55E) : (healthScore >= 70 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)), fontSize: 24, fontWeight: FontWeight.bold))),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: healthScore / 100.0,
                              minHeight: 8,
                              backgroundColor: const Color(0xFF121212),
                              color: healthScore >= 85 ? const Color(0xFF22C55E) : (healthScore >= 70 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("Risk", style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 10)),
                              Text("Healthy", style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 10)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String badge, Color badgeColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(badge, style: TextStyle(color: badgeColor, fontSize: 12)),
        ],
      ),
    );
  }
}
