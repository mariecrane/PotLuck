import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/controller/bloc/friend_bloc.dart';
import 'package:pot_luck/model/user.dart';

class AddFriendPage extends StatefulWidget {
  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  var _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add a Friend",
          style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w300,
              fontFamily: 'MontserratScript'),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Search for friends by email...",
                labelStyle: TextStyle(fontFamily: 'MontserratScript'),
              ),
            ),
          ),
          RaisedButton(
            elevation: 0.0,
            color: Colors.amber[100],
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0),
            ),
            child: Text(
              "Add",
              style: TextStyle(
                  fontSize: 17.0,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'MontserratScript'),
            ),
            onPressed: () {
              BlocProvider.of<FriendBloc>(context).add(
                FriendAddRequest(_controller.text),
              );
              Navigator.of(context).pop();
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                "Your Friends:",
                style: TextStyle(
                  fontFamily: "MontserratScript",
                  fontSize: 20,
                ),
              ),
            ),
          ),
          BlocBuilder<FriendBloc, FriendState>(
            condition: (before, after) {
              return (after is FriendsLoading) || (after is FriendsListUpdate);
            },
            builder: (context, state) {
              if (state is FriendsLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (state is FriendsListUpdate) {
                return ListView.builder(
                  key: PageStorageKey<String>("friends_list"),
                  itemCount: state.friendsList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return FriendTile(state.friendsList[index]);
                  },
                );
              }
              return Center(
                child: Text(
                  "Hmm, something went wrong...",
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class FriendTile extends StatelessWidget {
  final User _friend;
  FriendTile(this._friend);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: FirebaseImage(_friend.imageURI),
      ),
      title: Title(
        color: Colors.black,
        child: Text(
          _friend.email,
          style: TextStyle(fontSize: 17, fontFamily: 'MontserratScript'),
        ),
      ),
      trailing: IconButton(
        color: Colors.red,
        icon: Icon(Icons.remove_circle),
        onPressed: () {
          BlocProvider.of<FriendBloc>(context).add(
            FriendRemoveRequest(_friend),
          );
        },
      ),
    );
  }
}
