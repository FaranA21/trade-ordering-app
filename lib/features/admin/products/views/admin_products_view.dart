import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/features/admin/products/view_models/admin_products_state.dart';
import 'package:merchant_demo/features/admin/products/view_models/admin_products_view_model.dart';
import 'package:merchant_demo/features/admin/products/widgets/admin_product_card.dart';
import 'package:merchant_demo/features/admin/shell/widgets/admin_page.dart';

class AdminProductsView extends StatelessWidget {
  const AdminProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AdminProductsViewModel>();
    return BlocBuilder<AdminProductsViewModel, AdminProductsState>(
      builder: (context, s) {
        final list = s.visible;
        return AdminPage(
          title: 'Products',
          subtitle: '${s.products.length} products, ${s.outOfStock} out of stock, ${s.lowStock} running low. '
              'Price changes show in the buyer app straight away.',
          actions: [AdminSearchField(hint: 'Search name or SKU', onChanged: vm.search)],
          child: list.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('No products match.',
                      textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted)),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 300,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final p = list[i];
                    return AdminProductCard(
                      key: ValueKey(p.id),
                      product: p,
                      onSavePrice: (text) => vm.setPrice(p, text),
                      onAvailableChanged: (v) => vm.setAvailable(p, v),
                    );
                  },
                ),
        );
      },
    );
  }
}
