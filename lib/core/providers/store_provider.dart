import 'package:flutter/material.dart';
import '../enums/store_type.dart';

class StoreProvider extends ChangeNotifier {
  StoreType _currentStore = StoreType.restaurant;

  StoreType get currentStore => _currentStore;

  void setStore(StoreType type) {
    if (_currentStore != type) {
      _currentStore = type;
      notifyListeners();
    }
  }
}