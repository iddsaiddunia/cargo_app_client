import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  final String requestId;
  final String driverId;
  final double bidPrice;

  Request({required this.requestId, required this.driverId, required this.bidPrice});

  factory Request.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Request(
      requestId: doc.id,
      driverId: data['driverId'] ?? '',
      bidPrice: data['bidPrice']?.toDouble() ?? 0.0,
    );
  }
}
