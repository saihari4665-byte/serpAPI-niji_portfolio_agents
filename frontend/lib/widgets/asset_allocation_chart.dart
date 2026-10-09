import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AssetAllocationChart extends StatefulWidget {
  final Map<String, dynamic> scanData;

  const AssetAllocationChart({super.key, required this.scanData});

  @override
  State<AssetAllocationChart> createState() => _AssetAllocationChartState();
}

class _AssetAllocationChartState extends State<AssetAllocationChart> {
  int touchedIndex = -1;

  final List<Color> colors = [
    const Color(0xFF4F46E5), // Indigo
    const Color(0xFF0EA5E9), // Sky Blue
    const Color(0xFF10B981), // Emerald
    const Color(0xFFF59E0B), // Amber
    const Color(0xFF8B5CF6), // Violet
  ];

  @override
  Widget build(BuildContext context) {
    final sectorAllocation = widget.scanData['sector_allocation'] as List<dynamic>? ?? [];
    
    List<PieChartSectionData> sections = [];
    List<Widget> legendItems = [];
    
    int i = 0;
    for (var data in sectorAllocation) {
      final sector = data['sector'] as String? ?? 'Unknown';
      final weight = (data['percentage'] as num?)?.toDouble() ?? 0.0;
      final color = colors[i % colors.length];
      
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 70.0 : 60.0;
      final title = isTouched ? '$sector\n${weight.toStringAsFixed(1)}%' : '';
      
      sections.add(
        PieChartSectionData(
          color: color,
          value: weight.abs(),
          title: title,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          radius: radius,
        )
      );
      
      legendItems.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(sector, style: const TextStyle(color: Color(0xFFF8F9FA), fontWeight: FontWeight.w500, fontSize: 14), overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Text('${weight.toStringAsFixed(1)}%', style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 14)),
            ],
          ),
        )
      );
      
      i++;
    }

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
          const Text("Asset Allocation", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFA1A1AA))),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: sections,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: legendItems,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
