import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/controller/bloc/auth_bloc.dart';
import 'package:pot_luck/controller/bloc/profile_bloc.dart';
import 'package:pot_luck/model/user.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is NotSignedIn) {
          return Center(
            child: Column(
              children: <Widget>[
                Text(
                  "You're not signed in! Create an account or sign in to access all the features of PotLuck",
                  style: TextStyle(color: Colors.grey),
                ),
                RaisedButton(
                  child: Text("Go to sign-in"),
                  onPressed: () {
                    BlocProvider.of<AuthBloc>(context).add(SignOutRequested());
                  },
                ),
              ],
            ),
          );
        }

        if (state is DisplayingProfile) {
          return ProfileInfoListView(state.profile);
        }

        return Center(
          child: Text(
            "Hmm, something went wrong...",
            style: TextStyle(color: Colors.red),
          ),
        );
      },
    );
  }

  static Widget buildAppBar(BuildContext context) {
    return null;
  }

  static Widget buildFloatingActionButton(BuildContext context) {
    return null;
  }
}

class ProfileInfoListView extends StatelessWidget {
  final User profile;

  const ProfileInfoListView(this.profile, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: PageStorageKey<String>("profile_page"),
      children: ListTile.divideTiles(
        context: context,
        tiles: [
          new Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    //TODO: replace set image with image from user's account and add default if none provided
                    backgroundImage: FirebaseImage(profile.imageURI),
                    radius: 130.0,
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 0.0,
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Container(
              child: ListTile(
                //TODO: replace dummy data with data from user's account on database
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 10.0,
                ),
                title: Text(
                  profile.email,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'MontserratScript',
                  ),
                ),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            margin: EdgeInsets.all(10),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: RaisedButton(
              elevation: 0.0,
              onPressed: () {
                //TODO: implement pop up window to edit name, username, email, password, and photo
              },
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0),
                side: BorderSide(color: Colors.white),
              ),
              textColor: Colors.black,
              color: Colors.white,
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'MontserratScript'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: RaisedButton.icon(
              elevation: 0.0,
              onPressed: () {
                BlocProvider.of<AuthBloc>(context).add(SignOutRequested());
              },
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0),
                side: BorderSide(color: Colors.white),
              ),
              textColor: Colors.red,
              color: Colors.white,
              icon: Icon(Icons.exit_to_app),
              label: const Text(
                'Sign Out',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'MontserratScript'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: RaisedButton.icon(
              elevation: 0.0,
              onPressed: () async {
                bool delete = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        "This will permanently delete your account and all data tied to it. Are you sure you want to proceed?",
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        FlatButton(
                          child: Text("Proceed"),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );
                if (delete) {
                  BlocProvider.of<AuthBloc>(context).add(
                    AccountDeletionRequested(),
                  );
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0),
                side: BorderSide(color: Colors.white),
              ),
              textColor: Colors.red,
              color: Colors.white,
              icon: Icon(Icons.delete_forever),
              label: const Text(
                'Delete My Account',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'MontserratScript'),
              ),
            ),
          ),
        ],
      ).toList(),
    );
  }
}
