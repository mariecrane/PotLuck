import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/auth.dart';

class ProfilePage extends StatelessWidget {
  final Color color;

  ProfilePage(this.color);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: ListTile.divideTiles(
        context: context,
        tiles: [
          new Container(
            child: new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    //TODO: replace set image with image from user's account and add default if none provided
                    backgroundImage: NetworkImage("https://as1.ftcdn.net/jpg/00/20/71/56/500_F_20715690_qfB7YxRpr4RUWdwXIUzHDrHlOpxsh2yN.jpg"),
                    radius: 130.0,
                  )
                ]
              )
            )
          ),
          Card(
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Container(
                child: ListTile(
                  //TODO: replace dummy data with data from user's account on database
                    contentPadding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                    title: Text('John Doe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    subtitle: Text('Username: @jdoe\nEmail: jdoe@hotmail.com')
                )
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            margin: EdgeInsets.all(10),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: RaisedButton(
              onPressed: () {
                //TODO: implement pop up window to edit name, username, email, password, and photo
              },
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(20.0),
                  side: BorderSide(color: Colors.white)),
              textColor: Colors.black,
              color: Colors.white,
              child: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: RaisedButton.icon(
              onPressed: () {
                BlocProvider.of<AuthBloc>(context).dispatch(SignOutRequested());
              },
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(20.0),
                  side: BorderSide(color: Colors.white)),
              textColor: Colors.red,
              color: Colors.white,
              icon: Icon(Icons.exit_to_app),
              label: const Text(
                'Sign Out',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ).toList(),
    );
  }

  static Widget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1.0,
      title: Text("Profile", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 28)),
    );
  }
}
