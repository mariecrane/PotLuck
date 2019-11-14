import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/friend.dart';

class FriendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<FriendBloc, FriendState>(
        builder: (context, state) {
          if (state is FriendsListUpdate) {
            var tiles = List<Widget>();
            state.friendsList.forEach((friend) {
              tiles.add(FriendTile(friend));
            });

            return ListView(
              key: PageStorageKey<String>("friend_page"),
              padding: EdgeInsets.all(5.0),
              children: tiles,
            );
          }

          if (state is FriendsListEmpty) {
            return Center(
              child: Text(
                "Add friends using the + icon below",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

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

  static Widget buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => BlocProvider<FriendBloc>.value(
              value: BlocProvider.of<FriendBloc>(context),
              child: AddFriendPage(),
            ),
          ),
        );
      },
    );
  }
}

class FriendTile extends StatelessWidget {
  final Friend _friend;

  const FriendTile(this._friend, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20.0),
        child: ListTile(
          leading: CircleAvatar(
            child: FlutterLogo(),
            backgroundColor: Colors.white,
          ),
          title: Text(_friend.name),
        ),
        onTap: () {},
        onLongPress: () async {
          bool confirmed = await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => ConfirmRemoveFriendDialog(_friend),
          );
          if (confirmed != null && confirmed) {
            BlocProvider.of<FriendBloc>(context)
                .dispatch(FriendRemoved(_friend));
          }
        },
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    );
  }
}

class ConfirmRemoveFriendDialog extends StatelessWidget {
  final Friend _friend;

  const ConfirmRemoveFriendDialog(this._friend, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Remove ${_friend.name} from friends list?"),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        FlatButton(
          child: Text("Remove"),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}

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
        title: Text("Add a Friend"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: TextField(
              controller: _controller,
            ),
          ),
          RaisedButton(
            child: Text("Add"),
            onPressed: () {
              BlocProvider.of<FriendBloc>(context).dispatch(
                FriendAddRequest(_controller.text),
              );
              Navigator.of(context).pop();
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
