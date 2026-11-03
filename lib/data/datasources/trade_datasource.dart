import 'package:merchant_demo/data/models/app_session.dart';
import 'package:merchant_demo/data/models/cart_line.dart';
import 'package:merchant_demo/data/models/customer.dart';
import 'package:merchant_demo/data/models/order.dart';
import 'package:merchant_demo/data/models/order_status.dart';
import 'package:merchant_demo/data/models/product.dart';

/// Where the data comes from. Two implementations:
/// - FirestoreDatasource: Firebase Auth + Cloud Firestore (live, shared between devices)
/// - LocalJsonDatasource: assets/data JSON in memory (offline fallback)
///
/// The repository and everything above it do not know which one is in use.
abstract class TradeDatasource {
  /// The session restored from a previous sign-in, if any.
  Future<AppSession?> currentSession();

  /// Null when the account number or password is wrong.
  Future<AppSession?> signInBuyer(String accountNo, String password);

  /// Null when the details are wrong or the user is not branch staff.
  Future<AppSession?> signInAdmin(String email, String password);

  Future<void> signOut();

  /// Live lists. Each stream emits the full list again on every change.
  Stream<List<Product>> watchProducts();
  Stream<List<Customer>> watchCustomers(AppSession session);
  Stream<List<TradeOrder>> watchOrders(AppSession session);

  Future<void> updateProduct(String productId, {double? tradePrice, bool? available});
  Future<void> updateOrderStatus(String orderId, OrderStatus status);

  /// Creates the order, takes the stock and adds the total to the account,
  /// all in one step.
  Future<TradeOrder> placeOrder({
    required Customer customer,
    required List<CartLine> lines,
    required Fulfilment fulfilment,
    required String poReference,
  });
}
