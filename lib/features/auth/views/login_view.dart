import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:merchant_demo/core/constants/brand_config.dart';
import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/widgets/brand_mark.dart';
import 'package:merchant_demo/features/auth/view_models/auth_view_model.dart';
import 'package:merchant_demo/features/auth/view_models/auth_state.dart';
import 'package:merchant_demo/features/catalogue/view_models/catalogue_view_model.dart';
import 'package:merchant_demo/features/orders/view_models/orders_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginView> {
  final _account = TextEditingController(text: BrandConfig.demoAccountNo);
  final _password = TextEditingController(text: BrandConfig.demoPassword);

  @override
  void dispose() {
    _account.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() => context.read<AuthViewModel>().signIn(_account.text, _password.text);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthViewModel, AuthState>(
      listenWhen: (a, b) => !a.signedIn && b.signedIn,
      listener: (context, state) {
        // Load the customer's catalogue and orders. The router then moves to /shop.
        final id = state.customer!.id;
        context.read<CatalogueViewModel>().load(id);
        context.read<OrdersViewModel>().load(id);
      },
      child: Scaffold(
        backgroundColor: AppColors.ink,
        // Yard photo with a navy fade, as in the v2 design.
        body: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(BrandConfig.loginHero),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x260E2A47), Color(0xCC08182A), Color(0xFF08182A)],
                stops: [0, 0.45, 0.78],
              ),
            ),
            child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _Header(),
                          const SizedBox(height: 56),
                          Text(
                            'Order at your trade price, any time of day.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 34,
                              height: 1.12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textOnInk,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Reorder in one tap, pay on account and see when the van is on its way.',
                            style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFFC9D1D9)),
                          ),
                          const Spacer(),
                          const SizedBox(height: 28),
                          // White sign-in card, as in the v2 design.
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _Field(label: 'Account number', controller: _account),
                                const SizedBox(height: 12),
                                _Field(
                                  label: 'Password',
                                  controller: _password,
                                  obscure: true,
                                  onSubmitted: (_) => _submit(),
                                ),
                                const SizedBox(height: 16),
                                BlocBuilder<AuthViewModel, AuthState>(
                                  builder: (context, state) => Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      if (state.error != null)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: Text(state.error!,
                                              style: const TextStyle(color: AppColors.stockOut, fontSize: 13)),
                                        ),
                                      FilledButton(
                                        onPressed: state.loading ? null : _submit,
                                        child: state.loading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                              )
                                            : const Text('Sign in'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Demo account: Pennine Build & Renovate Ltd',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        BrandMark(),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(BrandConfig.companyName,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textOnInk)),
            Text(BrandConfig.companyTagline, style: TextStyle(fontSize: 14, color: AppColors.textOnInkMuted)),
          ],
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.obscure = false,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          onSubmitted: onSubmitted,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMain),
        ),
      ],
    );
  }
}
