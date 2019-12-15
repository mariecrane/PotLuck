import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/model/user.dart';

/// Authors: Marie Crane, Preston Locke
/// This is the business logic component for the profile page. It responds to
/// actions by the user on the profile page and supplies state information
/// back to the UI

/// An event emitted from the UI that is related to the user's profile
abstract class ProfileEvent {}

/// Signifies that the user has requested their profile image be set to the
/// image in [imageFile]
class PictureSelected extends ProfileEvent {
  final File imageFile;
  PictureSelected(this.imageFile);
}

/// Signifies that the user has requested their email be set to [email]. The
/// [auth] attribute must equal the user's current password
class EmailUpdated extends ProfileEvent {
  final String email;
  final String auth;
  EmailUpdated(this.email, this.auth);
}

/// Signifies that the user has requested their password be set to [password].
/// The [auth] attribute must equal the user's current password
class PasswordUpdated extends ProfileEvent {
  final String password;
  final String auth;
  PasswordUpdated(this.password, this.auth);
}

/// Signifies that the [ProfileBloc] has received updated information from the
/// backend about the user's profile info, such as email, image, etc.
class _ProfileUpdated extends ProfileEvent {
  final User profile;
  _ProfileUpdated(this.profile);
}

/// A state emitted from [ProfileBloc] to the UI
abstract class ProfileState {}

/// Signifies that [ProfileBloc] is currently performing state-changing
/// operations, such as changing the user's email, password, or profile image
class ProfileLoading extends ProfileState {}

/// Signifies that there is currently no user account signed in
class NotSignedIn extends ProfileState {}

/// Signifies that the UI should display the current [profile] information
class DisplayingProfile extends ProfileState {
  final User profile;
  DisplayingProfile(this.profile);
}

/// Accepts [ProfileEvent] objects from the UI, handles those events
/// accordingly, and emits [ProfileState] objects back to the UI
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
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
