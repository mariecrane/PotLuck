import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/model/user.dart';

/// Authors: Marie Crane, Preston Locke
/// This is the business logic component for the profile page. It handles all
/// interactions with the API or the database in response to actions by the user
/// on the profile page.

abstract class ProfileEvent {}
/// ProfileEvents are some of the possible actions that the user could take from
/// the profile page: selecting a picture or updating the email or password

class PictureSelected extends ProfileEvent {
  final File imageFile;
  PictureSelected(this.imageFile);
}

class EmailUpdated extends ProfileEvent {
  final String email;
  final String auth;
  EmailUpdated(this.email, this.auth);
}

class PasswordUpdated extends ProfileEvent {
  final String password;
  final String auth;
  PasswordUpdated(this.password, this.auth);
}

class _ProfileUpdated extends ProfileEvent {
  final User profile;
  _ProfileUpdated(this.profile);
}

abstract class ProfileState {}
/// ProfileState indicates the state of the profile as either loading, not
/// signed in, or displaying profile, which dictates to the UI what to show

class ProfileLoading extends ProfileState {}

class NotSignedIn extends ProfileState {}

class DisplayingProfile extends ProfileState {
  final User profile;
  DisplayingProfile(this.profile);
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  /// The ProfileBloc interacts with the database based on the ProfileEvent, to
  /// update the email, password, or picture
  ProfileBloc() {
    DatabaseController.instance.onAuthUpdate((profile) async {
      add(_ProfileUpdated(profile));
    });
  }

  @override
  ProfileState get initialState => ProfileLoading();

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is _ProfileUpdated) {
      if (event.profile == null || event.profile.isNobody) {
        yield NotSignedIn();
        return;
      }

      yield DisplayingProfile(event.profile);
    }

    if (event is EmailUpdated) {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      var credential = EmailAuthProvider.getCredential(
          email: user.email, password: event.auth);
      try {
        await user.reauthenticateWithCredential(credential);
      } catch (e) {
        debugPrint(e.toString());
      }
      await user.updateEmail(event.email);
      DatabaseController.instance.updateUserEmail(event.email);
    }

    if (event is PasswordUpdated) {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      var credential = EmailAuthProvider.getCredential(
          email: user.email, password: event.auth);
      try {
        await user.reauthenticateWithCredential(credential);
      } catch (e) {
        debugPrint(e.toString());
      }
      await user.updatePassword(event.password);
    }

    if (event is PictureSelected) {
      DatabaseController.instance.updateProfileImage(event.imageFile);
    }
  }
}
