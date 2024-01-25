import 'package:restaurant_admin/models/order.dart';

class Bill {
  final String id;
  final String status;
  final int pickUpCode;
  final List<Order> orders;
  final String? tableLabel;
  final int total;
  final int createdAt;
  final int offset;
  const Bill(
      {required this.id,
      required this.status,
      required this.orders,
      required this.pickUpCode,
      required this.total,
      required this.createdAt,
      required this.offset,
      this.tableLabel});
  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
        id: json['id'],
        status: json['status'],
        pickUpCode: json['pickUpCode'],
        tableLabel: json['tableLabel'],
        total: json['total'],
        createdAt: json['createdAt'],
        offset: json['offset'],
        orders: (json['orders'] as Iterable)
            .map((e) => Order.fromJson(e))
            .toList());
  }
}
