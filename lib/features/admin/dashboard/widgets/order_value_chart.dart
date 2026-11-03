import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/utils/formatters.dart';
import 'package:merchant_demo/features/admin/dashboard/view_models/dashboard_state.dart';

/// Bar chart of order value per day. The latest day is amber, the rest navy.
class OrderValueChart extends StatelessWidget {
  const OrderValueChart({super.key, required this.days});

  final List<DayValue> days;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return const Center(child: Text('No orders yet.', style: TextStyle(color: AppColors.textMuted)));
    }
    final maxY = days.map((d) => d.valueExVat).reduce((a, b) => a > b ? a : b) * 1.2;

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= days.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(Fmt.dayShort(days[i].day),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF8293A5))),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.ink,
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              Fmt.gbp(rod.toY),
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < days.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: days[i].valueExVat,
                  width: 30,
                  color: i == days.length - 1 ? AppColors.highlight : AppColors.ink.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
