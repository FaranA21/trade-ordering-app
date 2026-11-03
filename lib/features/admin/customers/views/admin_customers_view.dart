import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/theme/app_decor.dart';
import 'package:merchant_demo/core/utils/formatters.dart';
import 'package:merchant_demo/features/admin/customers/view_models/admin_customers_state.dart';
import 'package:merchant_demo/features/admin/customers/view_models/admin_customers_view_model.dart';
import 'package:merchant_demo/features/admin/shell/widgets/admin_page.dart';

class AdminCustomersView extends StatelessWidget {
  const AdminCustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCustomersViewModel, AdminCustomersState>(
      builder: (context, s) {
        return AdminPage(
          title: 'Trade customers',
          subtitle: '${s.customers.length} accounts, ${Fmt.gbp(s.totalOwed)} owed in total',
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 420,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              mainAxisExtent: 220,
            ),
            itemCount: s.customers.length,
            itemBuilder: (context, i) => _CustomerCard(summary: s.customers[i]),
          ),
        );
      },
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.summary});

  final CustomerSummary summary;

  @override
  Widget build(BuildContext context) {
    final c = summary.customer;
    final ratio = c.creditUsedRatio;
    final last = summary.lastOrderAt;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecor.card(radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(14)),
                child: Text(Fmt.initials(c.companyName),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.highlight)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.companyName,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    Text('${c.accountNo}, ${c.contactName}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                  ],
                ),
              ),
              if (c.discountPct > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3DC), borderRadius: BorderRadius.circular(10)),
                  child: Text('${c.discountPct.toStringAsFixed(0)}% off',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF92400E))),
                ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              const Expanded(
                child: Text('Credit used',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              ),
              Text('${Fmt.gbpWhole(c.balance)} of ${Fmt.gbpWhole(c.creditLimit)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              color: ratio > 0.45 ? AppColors.highlight : AppColors.ink,
              backgroundColor: const Color(0xFFEEF2F6),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _Mini(label: 'Orders', value: '${summary.orderCount}')),
              const SizedBox(width: 8),
              Expanded(child: _Mini(label: 'Terms', value: c.paymentTerms)),
              const SizedBox(width: 8),
              Expanded(child: _Mini(label: 'Last order', value: last == null ? 'None' : Fmt.dayShort(last))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.ground, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
