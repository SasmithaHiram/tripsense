import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/ai_recommendation.dart';

class RecommendationsInsights extends StatelessWidget {
  final List<AiRecommendation> items;
  final ValueChanged<int>? onSelectTopIndex;
  final ValueChanged<String>? onSelectCategory;
  const RecommendationsInsights({
    super.key,
    required this.items,
    this.onSelectTopIndex,
    this.onSelectCategory,
  });

  Map<String, int> _categoryCounts() {
    final map = <String, int>{};
    for (final r in items) {
      final c = (r.category ?? 'Unknown').trim();
      if (c.isEmpty) continue;
      map[c] = (map[c] ?? 0) + 1;
    }
    return map;
  }

  List<AiRecommendation> _topByScore(int n) {
    final sorted = [...items]
      ..sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));
    return sorted.take(n).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final cat = _categoryCounts();
    final top = _topByScore(5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'AI Insights',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 220,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Top by score'),
                        const SizedBox(height: 8),
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                        final title =
                                            top[group.x.toInt()].title;
                                        return BarTooltipItem(
                                          '$title\nScore: ${rod.toY.toStringAsFixed(1)}',
                                          const TextStyle(color: Colors.white),
                                        );
                                      },
                                ),
                                touchCallback: (evt, resp) {
                                  if (resp == null || resp.spot == null) return;
                                  final idx = resp.spot!.touchedBarGroupIndex;
                                  if (onSelectTopIndex != null)
                                    onSelectTopIndex!(idx);
                                },
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      if (idx < 0 || idx >= top.length) {
                                        return const SizedBox.shrink();
                                      }
                                      final title = top[idx].title;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 6.0,
                                        ),
                                        child: Text(
                                          title.length > 8
                                              ? '${title.substring(0, 8)}…'
                                              : title,
                                          style: const TextStyle(fontSize: 10),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: [
                                for (var i = 0; i < top.length; i++)
                                  BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: (top[i].score ?? 0).toDouble(),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('By category'),
                        const SizedBox(height: 8),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 24,
                              pieTouchData: PieTouchData(
                                enabled: true,
                                touchCallback: (evt, resp) {
                                  final idx =
                                      resp?.touchedSection?.touchedSectionIndex;
                                  if (idx == null) return;
                                  final key = cat.keys.elementAt(idx);
                                  if (onSelectCategory != null)
                                    onSelectCategory!(key);
                                },
                              ),
                              sections: [
                                ...cat.entries.map((e) {
                                  final total = cat.values.fold<int>(
                                    0,
                                    (p, c) => p + c,
                                  );
                                  final v = e.value.toDouble();
                                  final pct = total == 0
                                      ? 0.0
                                      : (v / total) * 100;
                                  return PieChartSectionData(
                                    value: v,
                                    title: '${pct.toStringAsFixed(0)}%',
                                    color: _colorFor(e.key, context),
                                    radius: 50,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: cat.keys
                              .map(
                                (k) => Chip(
                                  label: Text(k),
                                  backgroundColor: _colorFor(
                                    k,
                                    context,
                                  ).withOpacity(0.15),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _colorFor(String key, BuildContext context) {
    final palette = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
    ];
    final idx = key.hashCode.abs() % palette.length;
    return palette[idx];
  }
}
