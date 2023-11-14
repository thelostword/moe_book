import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:provider/provider.dart';
import 'reader.dart';
import '../provider.dart';


class ResultPage extends StatefulWidget {
  final String keyword;
  const ResultPage(this.keyword, {Key? key}) :super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late Future<List<Map<String, String>>> contentFuture;

  @override
  void initState() {
    super.initState();
    contentFuture = fetchData();
  }

  // 获取搜索结果
  Future<List<Map<String, String>>> fetchData() async {
    var response = await http.get(Uri.parse('http://www.xbiquzw.com/modules/article/search.php?searchkey=${widget.keyword}'));

    if (response.statusCode == 200) {
      var decodedBody = utf8.decode(response.bodyBytes);
      var document = html_parser.parse(decodedBody);
      var trElements = document.querySelectorAll('table.grid tbody tr');

      if (trElements.isNotEmpty) {
        List<Map<String, String>> dataList = [];

        for (var element in trElements) {
          var tdElements = element.querySelectorAll('td');

          if (tdElements.isNotEmpty) {
            var name = tdElements[0].querySelector('a')?.text;
            var bookId = tdElements[0].querySelector('a')?.attributes['href']?.replaceAll(r'/', '');
            var author = tdElements[2].text;
            var wordSize = tdElements[3].text;
            var updateTime = tdElements[4].text;
            var status = tdElements[5].text;

            if (name != null && bookId != null) {
              dataList.add({
                'name': name,
                'bookId': bookId,
                'author': author,
                'wordSize': wordSize,
                'updateTime': updateTime,
                'status': status
              });
            }
          }
        }
        return dataList;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索结果'),
      ),
      body: Center(
        child: GestureDetector(
          child: FutureBuilder<List<Map<String, String>>>(
            future: contentFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final String? val = snapshot.data![index]['bookId']?.replaceAll(RegExp(r'_'), '/');
                      final String? val1 = snapshot.data![index]['bookId']?.replaceAll(RegExp(r'\d+_'), '');
                      return ListTile(
                        leading: SizedBox(
                          width: 45,
                          height: 80,
                          child: Image.network(
                            'http://www.xbiquzw.com/files/article/image/$val/${val1}s.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(snapshot.data![index]['name'] ?? ''),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(snapshot.data![index]['author'] ?? ''),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Text(snapshot.data![index]['updateTime'] ?? '', style: TextStyle(color: Colors.grey.shade500)),
                                  const SizedBox(width: 8),
                                  Text(snapshot.data![index]['status'] ?? ''),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReaderPage(bookId: snapshot.data![index]['bookId'] ?? ''),
                            ),
                          );
                          final bookshelfProvider = Provider.of<BookshelfProvider>(context, listen: false);
                          bookshelfProvider.addBook(snapshot.data![index]);
                        },
                      );
                    },
                  )
                );
              } else {
                return const Text('No data available');
              }
            },
          ),
        ),
      ),
    );
  }
}
