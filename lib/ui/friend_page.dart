import 'package:flutter/material.dart';

class FriendPage extends StatelessWidget {
  final Color color;

  FriendPage(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
    );
  }
}