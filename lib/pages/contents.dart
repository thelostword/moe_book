import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider.dart';

class ContentsPage extends StatefulWidget {
  final String chapterId;

  const ContentsPage(this.chapterId, {Key? key}) :super(key: key);

  @override
  State<ContentsPage> createState() => _ContentsPageState();
}

class _ContentsPageState extends State<ContentsPage> {

  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();

    // 在页面加载后，延迟一段时间后执行滚动
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToId(widget.chapterId);
    });
  }

  void _scrollToId(String id) {
  // 使用ListView的ScrollController来滚动到指定位置
  final index = context.read<ContentsProvider>().contents.indexWhere((item) => item['href'] == id);
  if (index != -1) {
    _scrollController.animateTo(
      index * kToolbarHeight,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }
}

  Widget _buildContent() {
    if (context.read<ContentsProvider>().contents.isNotEmpty) {
      return ListView.builder(
        itemCount: context.read<ContentsProvider>().contents.length,
        itemBuilder: (context, index) {
          bool isHighlighted = context.read<ContentsProvider>().contents[index]['href'] == widget.chapterId;
          return ListTile(
            title: Text(
              context.read<ContentsProvider>().contents[index]['title'] ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            tileColor: isHighlighted ? (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColorLight) : null,
            onTap: () {
              Navigator.pop(context, context.read<ContentsProvider>().contents[index]['href'] ?? '');
            },
          );
        },
        controller: _scrollController,
      );
    } else {
      return const Text('No data available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('目录'),
      ),
      body: Center(
        child: GestureDetector(
          child: _buildContent(),
        ),
      ),
    );
  }
}
