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
}