import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:merchant_demo/core/constants/brand_config.dart';
import 'package:merchant_demo/core/routes/app_router.dart';
import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/widgets/brand_mark.dart';
import 'package:merchant_demo/features/auth/view_models/auth_view_model.dart';

/// Admin layout: navy side menu on wide screens, a drawer on narrow ones.
class AdminShellView extends StatelessWidget {
  const AdminShellView({super.key, required this.location, required this.child});

  /// Current path, used to highlight the menu item.
  final String location;
  final Widget child;

  static const double wideBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= wideBreakpoint;
        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(width: 240, child: _SideMenu(location: location)),
                Expanded(child: child),
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.ink,
            foregroundColor: Colors.white,
            title: const Text('Trade admin', style: TextStyle(color: Colors.white)),
          ),
          drawer: Drawer(
            backgroundColor: AppColors.ink,
            child: _SideMenu(location: location, closeOnTap: true),
          ),
          body: child,
        );
      },
    );
  }
}

class _SideMenu extends StatelessWidget {
  const _SideMenu({required this.location, this.closeOnTap = false});

  final String location;
  final bool closeOnTap;

  static const _items = [
    (Routes.admin, Icons.dashboard_outlined, 'Dashboard'),
    (Routes.adminOrders, Icons.receipt_long_outlined, 'Orders'),
    (Routes.adminProducts, Icons.inventory_2_outlined, 'Products'),
    (Routes.adminCustomers, Icons.people_outline, 'Customers'),
  ];

  bool _isSelected(String path) =>
      path == Routes.admin ? location == Routes.admin : location.startsWith(path);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 24),
                child: Row(
                  children: [
                    BrandMark(size: 38),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(BrandConfig.companyName,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                          Text('Trade admin', style: TextStyle(fontSize: 12, color: Color(0xFF9FB3C8))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              for (final (path, icon, label) in _items) ...[
                _MenuItem(
                  icon: icon,
                  label: label,
                  selected: _isSelected(path),
                  onTap: () {
                    if (closeOnTap) Navigator.of(context).pop();
                    context.go(path);
                  },
                ),
                const SizedBox(height: 6),
              ],
              const Spacer(),
              _MenuItem(
                icon: Icons.logout_rounded,
                label: 'Sign out',
                selected: false,
                onTap: () => context.read<AuthViewModel>().signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.ink : const Color(0xFFC8D3E0);
    return Material(
      color: selected ? AppColors.highlight : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 46,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 12),
                Text(label,
                    style: TextStyle(
                        fontSize: 14, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
