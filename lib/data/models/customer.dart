import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.accountNo,
    required this.companyName,
    required this.contactName,
    required this.email,
    required this.phone,
    required this.address,
    required this.paymentTerms,
    required this.creditLimit,
    required this.balance,
    required this.discountPct,
  });

  final String id;
  final String accountNo;
  final String companyName;
  final String contactName;
  final String email;
  final String phone;
  final String address;
  final String paymentTerms;
  final double creditLimit;

  /// Amount currently owed on account.
  final double balance;

  /// Trade discount off list price, e.g. 5 means 5%.
  final double discountPct;

  double get creditAvailable => creditLimit - balance;
  double get creditUsedRatio => creditLimit == 0 ? 0 : (balance / creditLimit).clamp(0, 1);

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as String,
        accountNo: json['accountNo'] as String,
        companyName: json['companyName'] as String,
        contactName: json['contactName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        address: json['address'] as String,
        paymentTerms: json['paymentTerms'] as String,
        creditLimit: (json['creditLimit'] as num).toDouble(),
        balance: (json['balance'] as num).toDouble(),
        discountPct: (json['discountPct'] as num).toDouble(),
      );

  Customer copyWith({double? balance}) => Customer(
        id: id,
        accountNo: accountNo,
        companyName: companyName,
        contactName: contactName,
        email: email,
        phone: phone,
        address: address,
        paymentTerms: paymentTerms,
        creditLimit: creditLimit,
        balance: balance ?? this.balance,
        discountPct: discountPct,
      );

  @override
  List<Object?> get props => [id, balance];
}
