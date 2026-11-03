import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:merchant_demo/core/constants/brand_config.dart';
import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/theme/app_decor.dart';
import 'package:merchant_demo/core/utils/formatters.dart';
import 'package:merchant_demo/features/auth/view_models/auth_view_model.dart';
import 'package:merchant_demo/features/cart/view_models/cart_view_model.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final customer = context.watch<AuthViewModel>().state.customer;
    if (customer == null) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('Account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(18)),
                  child: Text(Fmt.initials(customer.companyName),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.highlight)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.companyName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      Text('${customer.contactName}, account ${customer.accountNo}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppDecor.navy(radius: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Credit left on account',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textOnInkMuted)),
                      ),
                      if (customer.discountPct > 0)
                        Text('${customer.discountPct.toStringAsFixed(0)}% trade discount',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.highlight)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(Fmt.gbp(customer.creditAvailable),
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.8, color: Colors.white)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: customer.creditUsedRatio,
                      minHeight: 8,
                      color: AppColors.highlight,
                      backgroundColor: AppColors.inkRaised,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text('${Fmt.gbp(customer.balance)} owed',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textOnInkMuted)),
                      ),
                      Text('Limit ${Fmt.gbpWhole(customer.creditLimit)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textOnInkMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _InfoCard(label: 'Payment terms', value: customer.paymentTerms),
            const SizedBox(height: 12),
            _InfoCard(label: 'Delivery address', value: customer.address),
            const SizedBox(height: 12),
            const _InfoCard(label: 'Your branch', value: BrandConfig.branchAddress),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.stockOut,
                  side: const BorderSide(color: Color(0xFFE3E8EF), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                onPressed: () {
                  context.read<CartViewModel>().clear();
                  context.read<AuthViewModel>().signOut();
                },
                child: const Text('Sign out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecor.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
