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

  static Widget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1.0,
      title: Text("Friends", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 28)),
    );
  }
}
