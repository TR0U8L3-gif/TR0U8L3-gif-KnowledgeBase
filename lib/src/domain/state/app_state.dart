import 'package:flutter/material.dart';
import 'package:knowledge_base/src/data/models/article.dart';

class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Article? _selectedArticle;
  Article? get selectedArticle => _selectedArticle;

  void setSelectedArticle(Article? article) {
    _selectedArticle = article;
    notifyListeners();
  }
}
