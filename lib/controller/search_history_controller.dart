import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryController {
  static const String _key = 'recent_searches';
  static const int _maxHistorySize = 15;

  Future<List<String>> getSearchHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? <String>[];
  }

  Future<void> addSearchTerm(String term) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String trimmedTerm = term.trim();
    if (trimmedTerm.isEmpty) {
      return;
    }
    List<String> history = await getSearchHistory();
    history.removeWhere((item) => item.toLowerCase() == trimmedTerm.toLowerCase());
    history.insert(0, trimmedTerm);
    if (history.length > _maxHistorySize) {
      history = history.sublist(0, _maxHistorySize);
    }
    await prefs.setStringList(_key, history);
  }

  Future<void> clearSearchHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

