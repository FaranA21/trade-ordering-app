import 'package:flutter/material.dart';

import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/theme/app_decor.dart';

/// Page frame for admin screens: title, subtitle, optional actions, then content.
class AdminPage extends StatelessWidget {
  const AdminPage({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    required this.child,
    this.scroll = true,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget child;

  /// False when the child fills the space itself (e.g. a table).
  final bool scroll;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    final pad = narrow ? 16.0 : 32.0;
    final header = Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.end,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
            if (subtitle != null)
              Text(subtitle!,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          ],
        ),
        ...actions,
      ],
    );

    if (!scroll) {
      return Padding(
        padding: EdgeInsets.fromLTRB(pad, 28, pad, pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [header, const SizedBox(height: 20), Expanded(child: child)],
        ),
      );
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(pad, 28, pad, pad),
      children: [header, const SizedBox(height: 20), child],
    );
  }
}

/// White rounded search box used on admin pages.
class AdminSearchField extends StatelessWidget {
  const AdminSearchField({super.key, required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: AppDecor.card(radius: 14),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          fillColor: AppColors.surface,
          prefixIcon: const Icon(Icons.search, color: Color(0xFF8293A5)),
        ),
      ),
    );
  }
}
