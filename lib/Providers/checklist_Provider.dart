import 'package:flutter/material.dart';

class ChecklistProvider extends ChangeNotifier {
  Map<String, String> _items = {};

  Map<String, String> get items => _items;

  void addItems(List<String> checklist) {
    _items.clear(); // Clear previous items
    checklist.forEach((element) {
      _items[element] = ""; // Initialize each checklist item with an empty string
    });
    notifyListeners(); // Notify listeners to rebuild UI
  }

  void changeValue(String title, String value) {
    _items[title] = value;
    print(_items);
    notifyListeners();
  }

  bool areAllTagsSelected() {
    return !_items.containsValue("");
  }
}
