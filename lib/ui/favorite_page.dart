import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  final Color color;

  FavoritePage(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
    );
  }

  static Widget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 1.0,
      title: Text("PotLuck"),
    );
  }
}
