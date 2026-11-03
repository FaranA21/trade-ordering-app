import 'package:firebase_core/firebase_core.dart';
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
  // Web is the admin panel; Android/iOS are the buyer app (see app_router.dart).
  // Clean URLs on web (/admin instead of /#/admin). Needs web/_redirects on Netlify.
  usePathUrlStrategy();

  final TradeDatasource datasource;
  if (AppConfig.useFirebase) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    datasource = FirestoreDatasource();
  } else {
    datasource = LocalJsonDatasource();
  }

  final repository = TradeRepository(datasource);
  await repository.init();

  runApp(MerchantDemoApp(repository: repository));
}
