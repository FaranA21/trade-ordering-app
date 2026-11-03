import 'package:flutter/material.dart';

/// Everything you change to personalise the demo for a lead (30 to 60 minutes):
/// name, initials, colours, branch address. Products come from assets/data/products.json,
/// photos from assets/images/products/`<productId>`.jpg.
class BrandConfig {
  BrandConfig._();

  static const String companyName = 'Hollin & Marsh';
  static const String companyTagline = 'Trade Supply';
  static const String initials = 'H&M';
  static const String branchAddress = 'Hollin & Marsh, Kirkstall Road, Leeds LS4 2AZ';

  /// Deep navy: headers, main buttons, admin side menu.
  static const Color ink = Color(0xFF0E2A47);
  static const Color inkRaised = Color(0xFF1E4470);

  /// Main action colour (Add to order, Place order, selected chips).
  static const Color primary = Color(0xFF0E2A47);

  /// Amber accent, used for Reorder, the active nav item and highlights.
  static const Color highlight = Color(0xFFF5A524);

  /// Photo behind the sign-in screen.
  static const String loginHero = 'assets/images/hero_login.jpg';

  /// Demo login shown on the sign-in screen.
  static const String demoAccountNo = 'TA-4102';
  static const String demoPassword = 'demo1234';
}
