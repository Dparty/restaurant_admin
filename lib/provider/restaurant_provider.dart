import 'package:flutter/material.dart';
import 'package:restaurant_admin/models/restaurant.dart' as model;

class RestaurantProvider with ChangeNotifier {
  String _id = '';
  String _name = '';
  String _description = '';
  List<model.Item> _items = [];
  List<model.Printer> _printers = [];
  List<model.Table> _tables = [];
  List<String> _categories = [];

  String get id => _id;
  String get name => _name;
  String get description => _description;
  Map<String, Iterable<model.Item>> get itemsMap => classification(items);
  List<model.Item> get items => _items;

  List<model.Printer> get printers => _printers;
  List<model.Table> get tables => _tables;
  List<String> get categories => _categories;

  Map<String, Iterable<model.Item>> classification(Iterable<model.Item> items) {
    var itemsMap = <String, List<model.Item>>{};
    items.where((item) => item.tags.isNotEmpty).forEach((item) {
      if (!itemsMap.containsKey(item.tags[0])) {
        itemsMap[item.tags[0]] = <model.Item>[item];
      } else {
        itemsMap[item.tags[0]]!.add(item);
      }
    });
    return itemsMap;
  }

  void setRestaurant(
    String id,
    String name,
    String description,
    List<model.Item> items,
    List<model.Table> tables,
    List<String> categories,
  ) {
    _id = id;
    _name = name;
    _description = description;
    _items = items;
    _tables = tables;
    _categories = categories;
    notifyListeners();
  }

  void setRestaurantPrinter(List<model.Printer> printers) {
    _printers = printers;
    notifyListeners();
  }

  void resetRestaurant() {
    setRestaurant('', '', '', [], [], []);
    setRestaurantPrinter([]);
    notifyListeners();
  }
}
