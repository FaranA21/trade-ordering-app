import 'package:equatable/equatable.dart';

enum UserRole { buyer, admin }

/// Who is signed in. A buyer only sees their own account and orders;
/// an admin (branch staff) sees everything.
class AppSession extends Equatable {
  const AppSession({required this.uid, required this.role, this.customerId});

  final String uid;
  final UserRole role;

  /// Set for buyers. In Firebase the customer document id is the user's uid.
  final String? customerId;

  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [uid, role, customerId];
}
