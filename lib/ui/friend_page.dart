import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/friend.dart';

class FriendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) => FriendBloc(),
      child: BlocBuilder<FriendBloc, FriendState>(
        builder: (context, state) {
          return Container();
        },
      ),
    );
  }

  static Widget buildAppBar(BuildContext context) {
    return null;
//    return AppBar(
//      backgroundColor: Colors.white,
//      elevation: 1.0,
//      title: Text(
//        "Friends",
//        style: TextStyle(
//          fontWeight: FontWeight.bold,
//          color: Theme.of(context).primaryColor,
//          fontSize: 28,
//        ),
//      ),
//    );
  }
}
