import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pot_luck/controller/bloc/auth_bloc.dart';
import 'package:pot_luck/controller/bloc/profile_bloc.dart';
import 'package:pot_luck/model/user.dart';

/// Authors: Marie Crane, Preston Locke, Tracy Cai
/// This page shows the user's email and profile picture and includes options to
/// edit them and the password. Also includes "sign out" and "delete" buttons.

/// Body of the Profile page, either loading or displaying the user's profile.
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

/// Allows the user to change their email or password, after re-authentication
/// by entering their current password. Loaded when the user clicks on the
/// "Edit Profile" button.
class EditPage extends StatelessWidget {
  var _authController = TextEditingController();
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit profile",
          style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w300,
              fontFamily: 'MontserratScript'),
        ),
      ),
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _authController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Confirm your current password...",
                labelStyle: TextStyle(fontFamily: 'MontserratScript'),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter a new email...",
                labelStyle: TextStyle(fontFamily: 'MontserratScript'),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 80.0),
            child: RaisedButton(
              elevation: 0.0,
              color: Colors.amber[100],
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(25.0),
              ),
              child: Text(
                "Update email",
                style: TextStyle(
                    fontSize: 17.0,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'MontserratScript'),
              ),
              onPressed: () {
                BlocProvider.of<ProfileBloc>(context).add(
                    EmailUpdated(_emailController.text, _authController.text));
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter a new password...",
                labelStyle: TextStyle(fontFamily: 'MontserratScript'),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 70.0),
            child: RaisedButton(
              elevation: 0.0,
              color: Colors.amber[100],
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(25.0),
              ),
              child: Text(
                "Update password",
                style: TextStyle(
                    fontSize: 17.0,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'MontserratScript'),
              ),
              onPressed: () {
                BlocProvider.of<ProfileBloc>(context).add(PasswordUpdated(
                    _passwordController.text, _authController.text));
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows user's profile information in a list. Shows user's profile picture,
/// which can be edited by clicking on it. Also shows user's email and includes
/// buttons to edit profile, sign out, and delete account.
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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: new Center(
              child: InkWell(
                child: CircleAvatar(
                  backgroundImage: FirebaseImage(profile.imageURI),
                  radius: 130.0,
                ),
                onTap: () async {
                  var image = await ImagePicker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image == null) return;
                  var cropped = await ImageCropper.cropImage(
                    sourcePath: image.path,
                  );
                  if (cropped == null) return;
                  BlocProvider.of<ProfileBloc>(context).add(
                    PictureSelected(cropped),
                  );
                },
              ),
            ),
          ),
          Card(
            elevation: 0.0,
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Container(
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 10.0,
                ),
                title: Text(
                  profile.email,
                  textAlign: TextAlign.center,
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
                Navigator.of(context).push(CupertinoPageRoute(
                  builder: (_) => BlocProvider<ProfileBloc>.value(
                    value: BlocProvider.of<ProfileBloc>(context),
                    child: EditPage(),
                  ),
                ));
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
