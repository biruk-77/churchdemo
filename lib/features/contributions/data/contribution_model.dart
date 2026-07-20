import 'package:cloud_firestore/cloud_firestore.dart';

class ContributionModel {
  final String id;
  final String userId;
  final String churchId;
  final String type;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String paymentRef;
  final String status;
  final String receiptNo;
  final String? note;
  final DateTime createdAt;

  ContributionModel({
    required this.id,
    required this.userId,
    required this.churchId,
    required this.type,
    required this.amount,
    this.currency = 'ETB',
    required this.paymentMethod,
    required this.paymentRef,
    required this.status,
    required this.receiptNo,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'churchId': churchId,
      'type': type,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'paymentRef': paymentRef,
      'status': status,
      'receiptNo': receiptNo,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ContributionModel.fromMap(Map<String, dynamic> map, String id) {
    return ContributionModel(
      id: id,
      userId: map['userId'] ?? '',
      churchId: map['churchId'] ?? '',
      type: map['type'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] ?? 'ETB',
      paymentMethod: map['paymentMethod'] ?? '',
      paymentRef: map['paymentRef'] ?? '',
      status: map['status'] ?? 'pending',
      receiptNo: map['receiptNo'] ?? '',
      note: map['note'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
