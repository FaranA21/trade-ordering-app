import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:merchant_demo/core/theme/app_colors.dart';

/// Bottom navigation around the Shop, Orders and Account tabs.
/// The selected tab shows as a pill with its label; the others as icons.
class BuyerShellView extends StatelessWidget {
  const BuyerShellView({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _items = [
    (Icons.storefront_outlined, 'Shop'),
    (Icons.receipt_long_outlined, 'Orders'),
    (Icons.person_outline, 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(color: AppColors.ink.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -6)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (var i = 0; i < _items.length; i++)
                  _NavItem(
                    icon: _items[i].$1,
                    label: _items[i].$2,
                    selected: shell.currentIndex == i,
                    onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8EEF5) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: selected ? AppColors.ink : const Color(0xFF8293A5)),
              if (selected) ...[
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
