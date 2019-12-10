import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/model/user.dart';

abstract class ProfileEvent {}

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

class ProfileLoading extends ProfileState {}

class NotSignedIn extends ProfileState {}

class DisplayingProfile extends ProfileState {
  final User profile;
  DisplayingProfile(this.profile);
}

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
