import 'package:flutter/material.dart';
import 'package:restaurant_admin/models/restaurant.dart' as model;

class SelectedDiscountProvider with ChangeNotifier {
  model.Discount? _selectedDiscount;

  model.Discount? get selectedDiscount => _selectedDiscount;

  void setDiscount(model.Discount discount) {
    _selectedDiscount = discount;
    notifyListeners();
  }

  void resetSelectDiscount() {
    _selectedDiscount = null;
    notifyListeners();
  }
}
