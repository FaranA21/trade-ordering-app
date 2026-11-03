import 'package:flutter/material.dart';

import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/data/models/order.dart';
import 'package:merchant_demo/data/models/order_status.dart';

/// Horizontal 4-step tracker for the navy header:
/// done steps are amber with a tick, the current one glows white.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.order});

  final TradeOrder order;

  @override
  Widget build(BuildContext context) {
    final collect = order.fulfilment == Fulfilment.collection;
    final labels = ['Placed', 'Packed', collect ? 'Ready' : 'On the van', collect ? 'Collected' : 'Delivered'];
    final at = OrderStatus.values.indexOf(order.status);
    final complete = order.status == OrderStatus.delivered;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 4; i++)
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 24,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 3,
                              color: i == 0 ? Colors.transparent : (i <= at ? AppColors.highlight : AppColors.inkRaised),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Container(
                              height: 3,
                              color: i == 3 ? Colors.transparent : (i < at ? AppColors.highlight : AppColors.inkRaised),
                            ),
                          ),
                        ],
                      ),
                      _Dot(done: i < at || (complete && i == at), current: i == at && !complete),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: i <= at ? FontWeight.w800 : FontWeight.w600,
                    color: i <= at ? Colors.white : const Color(0xFF9FB3C8),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.done, required this.current});

  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.highlight : (current ? Colors.white : AppColors.inkRaised),
        boxShadow: current
            ? [BoxShadow(color: AppColors.highlight.withValues(alpha: 0.4), spreadRadius: 5)]
            : null,
      ),
      child: done ? const Icon(Icons.check_rounded, size: 15, color: AppColors.ink) : null,
    );
  }
}
