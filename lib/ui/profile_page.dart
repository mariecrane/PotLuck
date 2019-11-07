import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final Color color;

  ProfilePage(this.color);

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
