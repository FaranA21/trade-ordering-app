import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/theme/app_decor.dart';
import 'package:merchant_demo/core/utils/formatters.dart';
import 'package:merchant_demo/data/models/order.dart';
import 'package:merchant_demo/data/models/order_status.dart';
import 'package:merchant_demo/features/admin/orders/view_models/admin_orders_state.dart';
import 'package:merchant_demo/features/admin/orders/view_models/admin_orders_view_model.dart';
import 'package:merchant_demo/features/admin/shell/widgets/admin_page.dart';

class AdminOrdersView extends StatefulWidget {
  const AdminOrdersView({super.key, this.initialStatus});

  /// Status key from the URL, e.g. "placed" for the packing list.
  final String? initialStatus;

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> {
  @override
  void initState() {
    super.initState();
    final key = widget.initialStatus;
    context.read<AdminOrdersViewModel>().setFilter(key == null ? null : OrderStatus.fromKey(key));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AdminOrdersViewModel>();
    return BlocBuilder<AdminOrdersViewModel, AdminOrdersState>(
      builder: (context, s) {
        final rows = s.visible;
        return AdminPage(
          title: 'Orders',
          subtitle: 'Click a status to move the order on. The buyer sees it straight away.',
          scroll: false,
          actions: [AdminSearchField(hint: 'Search order or customer', onChanged: vm.search)],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(label: 'All', count: s.countOf(null), selected: s.filter == null, onTap: () => vm.setFilter(null)),
                  for (final st in OrderStatus.values)
                    _FilterChip(
                      label: st.label,
                      count: s.countOf(st),
                      selected: s.filter == st,
                      onTap: () => vm.setFilter(st),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: AppDecor.card(radius: 22),
                  clipBehavior: Clip.antiAlias,
                  child: rows.isEmpty
                      ? const Center(
                          child: Text('No orders match.', style: TextStyle(color: AppColors.textMuted)),
                        )
                      : DataTable2(
                          minWidth: 860,
                          columnSpacing: 16,
                          horizontalMargin: 22,
                          headingRowHeight: 48,
                          dataRowHeight: 62,
                          headingTextStyle:
                              const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF8293A5)),
                          dividerThickness: 1,
                          columns: const [
                            DataColumn2(label: Text('Order'), size: ColumnSize.S),
                            DataColumn2(label: Text('Customer'), size: ColumnSize.L),
                            DataColumn2(label: Text('Placed'), size: ColumnSize.S),
                            DataColumn2(label: Text('How'), size: ColumnSize.S),
                            DataColumn2(label: Text('Total'), size: ColumnSize.S, numeric: true),
                            DataColumn2(label: Text('Status'), size: ColumnSize.M),
                          ],
                          rows: [for (final o in rows) _row(o, vm)],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  DataRow2 _row(TradeOrder o, AdminOrdersViewModel vm) {
    final (bg, fg) = AppColors.statusColors(o.status);
    return DataRow2(
      cells: [
        DataCell(Text(o.orderNo, style: const TextStyle(fontWeight: FontWeight.w800))),
        DataCell(Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: const Color(0xFFE8EEF5), borderRadius: BorderRadius.circular(11)),
              child: Text(Fmt.initials(o.customerName),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(o.customerName,
                  overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        )),
        DataCell(Text(Fmt.when(o.placedAt), style: const TextStyle(color: AppColors.textMuted))),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(8)),
          child: Text(o.fulfilment == Fulfilment.delivery ? 'Delivery' : 'Collection',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textBody)),
        )),
        DataCell(Text(Fmt.gbp(o.total), style: const TextStyle(fontWeight: FontWeight.w800))),
        DataCell(Tooltip(
          message: o.status.next == null ? 'Reset to Placed (demo)' : 'Move to ${o.status.next!.label}',
          child: TextButton(
            onPressed: () => vm.advance(o),
            style: TextButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: fg,
              minimumSize: const Size(0, 34),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(o.statusLabel),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 14),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.count, required this.selected, required this.onTap});

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ink : AppColors.surface,
      borderRadius: BorderRadius.circular(13),
      elevation: selected ? 0 : 2,
      shadowColor: AppColors.ink.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.textBody)),
              const SizedBox(width: 8),
              Container(
                constraints: const BoxConstraints(minWidth: 24),
                height: 24,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: selected ? AppColors.highlight : const Color(0xFFF1F4F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$count',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w800, color: selected ? AppColors.ink : AppColors.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
