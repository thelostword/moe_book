import 'package:flutter/material.dart';
import 'package:moe_book/provider.dart';
import 'package:provider/provider.dart';
import 'pages/home.dart';
import 'pages/search.dart';
import 'pages/profile.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ContentsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BookshelfProvider(),
        ),
      ],
      child: const MyApp(),
    )
    // ChangeNotifierProvider(
    //   create: (_) => ContentsProvider(),
    //   child: const MyApp(),
    // )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange.shade300),
        primarySwatch: Colors.orange,
        useMaterial3: true
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange.shade300),
        primarySwatch: Colors.orange,
        useMaterial3: true
      ),
      themeMode: ThemeMode.system,
      home: const BottomTabBarExample(),
    );
  }
}

class BottomTabBarExample extends StatefulWidget {
  const BottomTabBarExample({super.key});

  @override
  State<BottomTabBarExample> createState() => _BottomTabBarExampleState();
}

class _BottomTabBarExampleState extends State<BottomTabBarExample> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: '书架',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '搜索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

