import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:merchant_demo/core/constants/app_config.dart';
import 'package:merchant_demo/core/constants/brand_config.dart';
import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/theme/app_decor.dart';
import 'package:merchant_demo/core/widgets/brand_mark.dart';
import 'package:merchant_demo/features/auth/view_models/auth_state.dart';
import 'package:merchant_demo/features/auth/view_models/auth_view_model.dart';

/// Staff sign-in for the admin panel. The router opens /admin once signed in.
class AdminLoginView extends StatefulWidget {
  const AdminLoginView({super.key});

  @override
  State<AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<AdminLoginView> {
  final _email = TextEditingController(text: AppConfig.adminEmail);
  final _password = TextEditingController(text: AppConfig.demoPassword);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() => context.read<AuthViewModel>().signInAdmin(_email.text, _password.text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: AppDecor.card(radius: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      BrandMark(size: 40),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(BrandConfig.companyName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                            Text('Trade admin', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Staff sign in', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  const Text('Manage orders, prices and stock for the trade app.',
                      style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 18),
                  BlocBuilder<AuthViewModel, AuthState>(
                    builder: (context, state) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(state.error!, style: const TextStyle(color: AppColors.stockOut, fontSize: 13)),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
