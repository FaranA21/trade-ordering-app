# Merchant demo app (concept, not client work)

Trade buyer app and admin panel for a fictional UK wholesaler, "Hollin & Marsh".
One codebase, two products: **Android/iOS = buyer app only, web = admin panel only** (see core/routes/app_router.dart).
Flutter, BLoC (cubits), go_router, local JSON behind one repository class.

## First run
1. Unzip, open the folder in a terminal.
2. `flutter create . --platforms=android,ios,web --project-name merchant_demo`
   (adds the platform folders; it does not overwrite lib/ or pubspec.yaml)
3. Delete `test/widget_test.dart` (it refers to a MyApp class that does not exist).
4. `flutter pub get`
   If a version clashes with your Flutter SDK: `flutter pub upgrade --major-versions`
5. `flutter run -d chrome` for the admin panel, or an Android device for the buyer app.
6. Demo login: TA-4102 / demo1234 (any account number in customers.json works with demo1234).

## Netlify
- `flutter build web --release`
- Drag `build/web` into Netlify. This is the admin panel. `web/_redirects` is copied in so /admin/... works on refresh.

## Architecture: MVVM, feature-first
- Model: `data/` (models, datasource, repository). The repository is the single source of truth.
- ViewModel: one Cubit per feature, named `*ViewModel`, with an immutable `*State`. Holds all logic.
- View: widgets in `views/` only read state and call view-model methods. No logic, no data access.
- Swap to Firebase: write a new datasource with the same three methods. Views and view models do not change.

## Folder structure
```
assets/
  data/                 products.json (30), customers.json (5), orders.json (15)
  images/               hero_login.jpg, products/<productId>.jpg
lib/
  main.dart, app.dart   start-up, providers, MaterialApp.router
  core/
    constants/          brand_config.dart (change per lead)
    routes/             app_router.dart
    theme/              app_colors.dart, app_theme.dart
    utils/              formatters.dart
    widgets/            shared: product_image, status_badge, stock_label, qty_stepper, brand_mark
  data/
    models/             product, customer, order, order_item, order_status, cart_line
    datasources/        local_json_datasource.dart
    repositories/       trade_repository.dart
  features/
    auth/               views/login_view.dart, view_models/auth_view_model.dart + auth_state.dart
    shell/              views/buyer_shell_view.dart (bottom navigation)
    catalogue/          views/catalogue_view.dart, product_detail_view.dart, view_models/, widgets/
    cart/               views/cart_view.dart, view_models/
    orders/             views/orders_view.dart, order_detail_view.dart, view_models/, widgets/
    account/            views/account_view.dart
    admin/
      shell/            views/admin_shell_view.dart (side menu or drawer), widgets/admin_page.dart
      dashboard/        views/, view_models/, widgets/order_value_chart.dart (fl_chart)
      orders/           views/admin_orders_view.dart (data_table_2), view_models/
      products/         views/, view_models/, widgets/admin_product_card.dart
      customers/        views/, view_models/
```

## Product photos
- 24 products use Unsplash photos, hotlinked from products.json (`imageUrl`), as Unsplash's terms require. Each shows a "Photo by X on Unsplash" credit on the product page.
- 6 timber and copper products use local files in assets/images/products/.
- To change a photo: replace `imageUrl` in products.json, or delete it and drop a file named <productId>.jpg into assets/images/products/.

## Backend (Firebase)
- Firebase Auth (email and password) and Cloud Firestore, on the free Spark plan. No Cloud Functions.
- Buyers sign in with their account number (TA-4102 becomes ta-4102@hm-trade.example.com behind the scenes).
- Staff sign in at /admin/login (admin@hm-trade.example.com). All passwords: demo1234.
- Rules in firestore.rules: buyers see only their own account and orders; only staff change order status and prices.
- Placing an order is one Firestore transaction: order number, order, stock and account balance together.

### One-time setup
1. `dart pub global activate flutterfire_cli`, then `flutterfire configure` (pick the Firebase project, platforms web and android). This replaces lib/firebase_options.dart.
2. In the Firebase console: Authentication > Sign-in method > enable Email/Password. Firestore Database > Create database.
3. `firebase deploy --only firestore:rules`
4. Firebase console > Project settings > Service accounts > Generate new private key. Save it as tool/seed/serviceAccountKey.json (never share it).
5. `cd tool/seed`, `npm install`, `node seed.js`. Run it again any time to reset the demo.

### Offline mode
`flutter run -d chrome --dart-define=USE_FIREBASE=false` uses the JSON in assets/data instead.

## How to show it in the demo video
- Phone (or Android emulator): `flutter run -d <device>`. Sign in as TA-4102, tap Reorder, place the order.
- Browser: `flutter run -d chrome`, sign in as staff. The new order appears at the top of Orders straight away.
- Click its status on the web panel; the order status page on the phone updates live.
- Reset the data before recording: `node tool/seed/seed.js`.

## Demo data notes
- Prices are GBP ex VAT. Each customer has a trade discount (0 to 5%) applied on top.
- Order dates move forward on start so the newest order is always "today".
- In offline mode, changes live in memory until the page is refreshed. With Firebase they are saved.
