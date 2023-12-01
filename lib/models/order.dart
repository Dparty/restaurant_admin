import 'package:restaurant_admin/models/model.dart';
import 'package:restaurant_admin/models/restaurant.dart';

class Order {
  final Item item;
  final Iterable<Pair> specification;
  const Order({
    required this.item,
    required this.specification,
  });
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
        item: Item.fromJson(json['item']),
        specification:
            (json['specification'] as Iterable).map((e) => Pair.fromJson(e)));
  }
}
