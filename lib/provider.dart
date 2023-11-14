import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';

// 书架
class BookshelfProvider extends ChangeNotifier {
  final List<Map<String, String>> _bookshelf = [];

  List<Map<String, String>> get bookshelf => _bookshelf;

  // 添加书籍到书架
  void addBook(Map<String, String> book) {
    final includeBook = _bookshelf.firstWhere((element) => element['bookId'] == book['bookId'], orElse: () => {});
    if (includeBook['bookId'] == null) {
      _bookshelf.insert(0, book);
    } else if (_bookshelf.indexWhere((element) => element['bookId'] == book['bookId']) != 0) {
      _bookshelf.removeWhere((element) => element['bookId'] == book['bookId']);
      _bookshelf.insert(0, includeBook);
    }
    notifyListeners();
    _updateSharedPreferences();
  }

  bool hasBook(String bookId) {
    final includeBook = _bookshelf.firstWhere((element) => element['bookId'] == bookId, orElse: () => {});
    return includeBook['bookId'] == null;
  }

  // 从书架删除书籍
  void removeBook(String bookId) {
    _bookshelf.removeWhere((book) => book['bookId'] == bookId);
    notifyListeners();
    _updateSharedPreferences();
  }

  // 更新预设数据
  void _updateSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('bookshelf', jsonEncode(_bookshelf));
  }

  // 将指定索引的数据移动到索引0
  Map<String, String> moveToFirstAt(int index) {
    final targetBook = _bookshelf.removeAt(index);
    _bookshelf.insert(0, targetBook);
    notifyListeners();
    _updateSharedPreferences();
    return targetBook;
  }


  // 初始化数据
  Future<void> initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? bookshelfStr = prefs.getString('bookshelf');

    if (bookshelfStr != null) {
      List<dynamic> decodedData = jsonDecode(bookshelfStr);

      List<Map<String, String>> decodedBookshelf = List<Map<String, String>>.from(decodedData.map((item) {
        return Map<String, String>.from(item);
      }));

      _bookshelf.clear();
      _bookshelf.addAll(decodedBookshelf);
    }
  }
}


// 当前阅读目录
class ContentsProvider extends ChangeNotifier {
  List<Map<String, String>> _contents = [];

  List<Map<String, String>> get contents => _contents;

  void setContents(List<Map<String, String>> newContents) {
    _contents = newContents;
    notifyListeners();
  }
}

