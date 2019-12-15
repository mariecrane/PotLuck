import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/model/user.dart';

/// Authors: Preston Locke
/// This is the business logic component for authentication-related events. It
/// responds to actions by the user and supplies state information back to the UI

/// An authentication-related event emitted from the UI
abstract class AuthEvent {}

/// Signifies that the user has requested anonymous login
class AnonymousAuthRequested extends AuthEvent {}

/// Signifies that the user has requested a new account be created with the
/// given [email] and [password]
class AccountCreationRequested extends AuthEvent {
  final String email;
  final String password;

  AccountCreationRequested({@required this.email, @required this.password});
}

/// Signifies that the user has requested to delete the current account
class AccountDeletionRequested extends AuthEvent {}

/// Signifies that the user has requested to sign into an account with the given
/// [email] and [password]
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested({@required this.email, @required this.password});
}

/// Signifies that the user has requested to sign out of the current account
class SignOutRequested extends AuthEvent {}

/// Signifies that the [AuthBloc] has received updated authentication
/// information from the backend. This is triggered upon successful login
/// attempts, as well as changes to the currently logged-in user's information.
class _AuthChanged extends AuthEvent {
  final User currentUser;
  _AuthChanged(this.currentUser);
}

/// An authentication state emitted from [AuthBloc] to the UI
abstract class AuthState {}

/// Signifies that the [AuthBloc] is still initializing
class Initializing extends AuthState {}

/// Signifies that the user has been successfully authenticated
class Authenticated extends AuthState {}

/// Signifies that the user is not currently authenticated
class NotAuthenticated extends AuthState {}

/// Signifies that the [AuthBloc] is currently performing authentication
class AuthInProgress extends AuthState {}

/// Signifies that the [AuthBloc] encountered some kind of error
class AuthError extends AuthState {}

/// Accepts [AuthEvent] objects from the UI, handles those events accordingly,
/// and emits [AuthState] objects back to the UI
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
