import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:flutter/services.dart';
import 'contents.dart';
import '../provider.dart';


class ReaderPage extends StatefulWidget {
  final String bookId;
  final String? chapterId;
  
  const ReaderPage(
    {
      required this.bookId,
      this.chapterId,
      Key? key
    }
  ) :super(key: key);

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  // late Future<String> contentFuture;
  late List<Map<String, String>> _contents = [];
  late String _content = '';
  late String _chapterId;
  bool _loading = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _chapterId = widget.chapterId ?? '';
    if (_chapterId.isEmpty) getChapterContentFromSharedPreferences();
  }

  // @override
  // void dispose() {
  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  //   super.dispose();
  // }

  // 获取历史观看章节
  Future<void> getChapterContentFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedChapterId = prefs.getString('${widget.bookId}_chapterId');

    if (savedChapterId != null) {
      _chapterId = savedChapterId;
    }

    await fetchData(_chapterId);
  }

  // 设置当前观看章节
  Future<void> saveChapterIdAndGetContent(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('${widget.bookId}_chapterId', value);
    await fetchData(value);
  }

  // 获取目录
  Future<List<Map<String, String>>> fetchContents() async {
    var response = await http.get(Uri.parse('http://www.xbiquzw.com/${widget.bookId}/'));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final document = html_parser.parse(decodedBody);
      final ddElements = document.querySelectorAll('#list dl dd');

      if (ddElements.isNotEmpty) {
        
        // 基本信息提取
        if (context.mounted) {
          final bookshelfProvider = Provider.of<BookshelfProvider>(context, listen: false);

          if (bookshelfProvider.hasBook(widget.bookId)) {
            final String name = document.querySelector('#info h1')!.text;
            final Map<String, String> bookInfo = {
              'name': name,
              'bookId': widget.bookId,
              'author': '未知',
              'wordSize': '-',
              'updateTime': '-',
              'status': '-'
            };

            bookshelfProvider.addBook(bookInfo);
          }
        }

        // 目录提取
        List<Map<String, String>> dataList = [];

        for (var element in ddElements) {
          var title = element.querySelector('a')?.attributes['title'];
          var href = element.querySelector('a')?.attributes['href'];

          if (title != null && href != null) {
            dataList.add({'title': title, 'href': href});
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

  // 获取详情
  Future<void> fetchData(String chapterId) async {
    if (_loading) return;
    if (_contents.isEmpty) {
      _contents = await fetchContents();
      if (context.mounted) {
        final contentsProvider = Provider.of<ContentsProvider>(context, listen: false);
        contentsProvider.setContents(_contents);
      }
    }
    if (_contents.isEmpty) {
      setState(() {
        _content = '目录获取失败！';
      });
      return;
    }

    setState(() {
      _loading = true;
    });
    var response = await http.get(Uri.parse('http://www.xbiquzw.com/${widget.bookId}/${chapterId.isEmpty ? _contents[0]['href'] : chapterId}'));
    if (chapterId.isEmpty) _chapterId = _contents[0]['href'] ?? '';
    
    if (response.statusCode == 200) {
      var decodedBody = utf8.decode(response.bodyBytes);
      var document = html_parser.parse(decodedBody);
      var contentElement = document.querySelector('#content');

      if (contentElement != null) {
        var contentWithBreaks = contentElement.innerHtml.replaceAll('<br>', '\n');
        setState(() {
          _content = html_parser.parse(contentWithBreaks).body?.text ?? '';
        });
      } else {
        setState(() {
          _content = '内容不存在！';
        });
      }
    } else {
      setState(() {
        _content = 'Request failed with status: ${response.statusCode}';
      });
    }
    setState(() {
      _loading = false;
    });

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  // 上一章
  Future<void> _prevData() async {
    int ndx = _contents.indexWhere((element) => element['href'] == _chapterId);
    if (ndx == -1) return;
    if (ndx > 0) {
      _chapterId = _contents[ndx - 1]['href'] ?? '';
      await saveChapterIdAndGetContent(_chapterId);
    } else {
      Fluttertoast.showToast(
        msg: "已经是第一章了！",
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  // 刷新
  Future<void> _refreshData() async {
    await saveChapterIdAndGetContent(_chapterId);
  }

  // 下一章
  Future<void> _nextData() async {
    int ndx = _contents.indexWhere((element) => element['href'] == _chapterId);
    if (ndx == -1) return;
    if (ndx < _contents.length - 1) {
      _chapterId = _contents[ndx + 1]['href'] ?? '';
      await saveChapterIdAndGetContent(_chapterId);
    } else {
      Fluttertoast.showToast(
        msg: "已经是最后章了！",
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        // 处理上一页操作
                        _prevData();
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back),
                          SizedBox(width: 5),
                          Text('上一章'),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _refreshData();
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.refresh),
                          SizedBox(width: 5),
                          Text('刷新'),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // 处理下一页操作
                        _nextData();
                      },
                      child: const Row(
                        children: [
                          Text('下一章'),
                          SizedBox(width: 5),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final String? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContentsPage(_chapterId),
                          ),
                        );
                        if (result != null) {
                          _chapterId = result;
                          await saveChapterIdAndGetContent(_chapterId);
                        }
                      },
                      child: const Column(
                        children: [
                          Icon(Icons.menu),
                          SizedBox(width: 5),
                          Text('目录'),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 处理设置操作
                      },
                      child: const Column(
                        children: [
                          Icon(Icons.settings),
                          SizedBox(width: 5),
                          Text('设置'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildContent() {
    if (_content.isEmpty || _loading) {
      return const CircularProgressIndicator();
    } else {
      return SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _content,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.grey.shade700,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // ThemeData theme = Theme.of(context);
    
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('首页'),
      // ),
      body: Center(
        child: GestureDetector(
          onTap: _showBottomSheet,
          child: _buildContent(),
        ),
      ),
      // backgroundColor: theme.brightness == Brightness.light? Colors.white : Colors.black,
    );
  }
}
