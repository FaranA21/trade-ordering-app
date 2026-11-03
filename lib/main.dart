import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:merchant_demo/app.dart';
import 'package:merchant_demo/core/constants/app_config.dart';
import 'package:merchant_demo/data/datasources/firestore_datasource.dart';
import 'package:merchant_demo/data/datasources/local_json_datasource.dart';
import 'package:merchant_demo/data/datasources/trade_datasource.dart';
import 'package:merchant_demo/data/repositories/trade_repository.dart';
import 'package:merchant_demo/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Clean URLs on web (/admin instead of /#/admin). Needs web/_redirects on Netlify.
  usePathUrlStrategy();

  final TradeDatasource datasource;
  if (AppConfig.useFirebase) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    if (kIsWeb) {
      // One sign-in per browser tab, so the buyer app and the admin panel can
      // run side by side in two tabs for the demo.
      await FirebaseAuth.instance.setPersistence(Persistence.SESSION);
    }
    datasource = FirestoreDatasource();
  } else {
    datasource = LocalJsonDatasource();
  }

  final repository = TradeRepository(datasource);
  await repository.init();

  runApp(MerchantDemoApp(repository: repository));
}
