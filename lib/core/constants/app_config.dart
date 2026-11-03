/// Build-time switches.
///
/// Firebase is on by default. To run with the local JSON data instead
/// (no internet, no Firebase project), build with:
///   flutter run -d chrome --dart-define=USE_FIREBASE=false
class AppConfig {
  AppConfig._();

  static const bool useFirebase = bool.fromEnvironment('USE_FIREBASE', defaultValue: true);

  /// Buyers sign in with their account number. Firebase Auth needs an email,
  /// so the account number is turned into one: TA-4102 -> ta-4102@hm-trade.example.com
  static const String buyerEmailDomain = 'hm-trade.example.com';

  static const String adminEmail = 'admin@hm-trade.example.com';
  static const String demoPassword = 'demo1234';

  static String emailForAccount(String accountNo) => '${accountNo.trim().toLowerCase()}@$buyerEmailDomain';
}
