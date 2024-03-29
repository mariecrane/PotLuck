import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/controller/bloc/friend_bloc.dart';
import 'package:pot_luck/controller/bloc/friend_requests_bloc.dart';
import 'package:pot_luck/model/user.dart';

/// Authors: Preston Locke, Shouayee Vue, Tracy Cai
/// Last Updated 12/11/2019
/// friend_page.dart is the page where users can see friend requests, add,
/// and delete friends. It is an extension from the floating icon from the search_page.dart

/// The body of the Friends page
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
      body: ListView(
        children: <Widget>[
          Padding(
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 130.0),
            child: RaisedButton(
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
                BlocProvider.of<FriendRequestsBloc>(context).add(
                  FriendAddRequest(_controller.text),
                );
                Navigator.of(context).pop();
              },
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                "Friend Requests:",
                style: TextStyle(
                  fontFamily: "MontserratScript",
                  fontSize: 20,
                ),
              ),
            ),
          ),
          BlocBuilder<FriendRequestsBloc, FriendRequestsState>(
            builder: (context, state) {
              if (state is FriendRequestsLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (state is FriendRequestsUpdate) {
                return ListView.builder(
                  key: PageStorageKey<String>("request_list"),
                  itemCount: state.friendRequests.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return RequestTile(state.friendRequests[index]);
                  },
                );
              }
              return Center(
                child: Text(
                  "You Have No Friend Requests",
                  style: TextStyle(
                      color: Colors.red, fontFamily: "MontserratScript"),
                ),
              );
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
          BlocBuilder<FriendsListBloc, FriendsListState>(
            builder: (context, state) {
              if (state is FriendsListLoading) {
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

/// A [ListTile] representing one of the user's current friends
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
        onPressed: () async {
          bool delete = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "Are you sure you want to unfriend?",
                  style: TextStyle(fontFamily: 'MontserratScript'),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontFamily: 'MontserratScript'),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  FlatButton(
                    child: Text(
                      "Proceed",
                      style: TextStyle(fontFamily: 'MontserratScript'),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          );
          if (delete) {
            BlocProvider.of<FriendsListBloc>(context).add(
              FriendRemoveRequest(_friend),
            );
          }
        },
      ),
    );
  }
}

/// A [ListTile] representing a friend request from a user
class RequestTile extends StatelessWidget {
  final User _friend;
  RequestTile(this._friend);

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
        color: Colors.green,
        icon: Icon(Icons.add_circle),
        onPressed: () {
          BlocProvider.of<FriendRequestsBloc>(context).add(
            FriendAddRequest(_friend.email),
          );
        },
      ),
    );
  }
}
