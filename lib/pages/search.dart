import 'package:flutter/material.dart';
import 'result.dart';
import 'reader.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  void _handleSearch() {
    String keyword = _searchController.text;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(keyword),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '输入关键字搜索...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _handleSearch,
              ),
            ),
            onSubmitted: (String keyword) {
              if (keyword.startsWith(RegExp(r'^\$\d+_'))) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReaderPage(bookId: keyword.replaceFirst('\$', '')),
                  ),
                );
              } else {
                _handleSearch();
              }
            },
          ),
        ),
      ),
    );
  }
}
