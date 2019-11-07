import 'package:flutter/material.dart';

class PantryPage extends StatelessWidget {
  final Color color;

  PantryPage(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
    );
  }
}