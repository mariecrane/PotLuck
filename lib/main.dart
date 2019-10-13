import 'package:flutter/material.dart';

import 'ui/search_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PotLuck',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SearchPage(title: 'PotLuck Search Page'),
    );
  }
}
