import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'reader.dart';
import '../provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  Future<List<Map<String, String>>> _loadData() async {
    final bookshelfProvider = Provider.of<BookshelfProvider>(context);
    await bookshelfProvider.initData();
    return bookshelfProvider.bookshelf;
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的书架'),
      ),
      body: Center(
        child: FutureBuilder<List<Map<String, String>>>(
          future: _loadData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final bookshelfProvider = Provider.of<BookshelfProvider>(context, listen: false);
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  final String val = snapshot.data![index]['bookId']!.replaceAll(RegExp(r'_'), '/');
                  final String val1 = snapshot.data![index]['bookId']!.replaceAll(RegExp(r'\d+_'), '');
                  return Dismissible(
                    key: Key(snapshot.data![index]['bookId']!),
                    onDismissed: (direction) {
                      bookshelfProvider.removeBook(snapshot.data![index]['bookId']!);
                    },
                    child: ListTile(
                      leading: SizedBox(
                        width: 45,
                        height: 80,
                        child: Image.network(
                          'http://www.xbiquzw.com/files/article/image/$val/${val1}s.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(snapshot.data![index]['name']!),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(snapshot.data![index]['author']!),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Text(snapshot.data![index]['updateTime']!, style: TextStyle(color: Colors.grey.shade500)),
                                const SizedBox(width: 8),
                                Text(snapshot.data![index]['status']!),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        final thatBook = bookshelfProvider.moveToFirstAt(index);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReaderPage(bookId: thatBook['bookId']!),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            } else {
              return const Text('还没有观看过任何书籍');
            }
          },
        )
      ),
    );
  }
}
