import 'package:flutter/material.dart';

class PantryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  static Widget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1.0,
      title: Text(
        "Pantry",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
          fontSize: 28,
        ),
      ),
    );
  }
}
