import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/model/user.dart';

/// Encodes the type and data of events coming from our auth UI
abstract class AuthEvent {}

class AnonymousAuthRequested extends AuthEvent {}

class AccountCreationRequested extends AuthEvent {
  final String email;
  final String password;

  AccountCreationRequested({@required this.email, @required this.password});
}

class AccountDeletionRequested extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested({@required this.email, @required this.password});
}

class SignOutRequested extends AuthEvent {}

class _AuthChanged extends AuthEvent {
  final User currentUser;
  _AuthChanged(this.currentUser);
}

/// Encodes the status and data of results returned from Firebase Auth
abstract class AuthState {}

class Initializing extends AuthState {}

class Authenticated extends AuthState {}

class NotAuthenticated extends AuthState {}

class AuthInProgress extends AuthState {}

class AuthError extends AuthState {}

/// Connects our business logic with our UI code in an extensible way
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() {
    DatabaseController.instance.onAuthUpdate((currentUser) {
      add(_AuthChanged(currentUser));
    });
  }

  @override
  AuthState get initialState => Initializing();

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is _AuthChanged) {
      yield (event.currentUser != null) ? Authenticated() : NotAuthenticated();
    }

    if (event is AccountDeletionRequested) {
      yield AuthInProgress();
      DatabaseController.instance.deleteAccount();
    }

    if (event is AnonymousAuthRequested) {
      yield AuthInProgress();
      DatabaseController.instance.signInAnonymously();
    }

    if (event is SignInRequested) {
      yield AuthInProgress();
      DatabaseController.instance.signIn(event.email, event.password);
    }

    if (event is AccountCreationRequested) {
      yield AuthInProgress();
      DatabaseController.instance.createAccount(event.email, event.password);
    }

    if (event is SignOutRequested) {
      DatabaseController.instance.signOut();
    }
  }
}
