import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

/// Encodes the type and data of events coming from our search UI
abstract class AuthEvent {}

class AuthResult extends AuthEvent {}

class AuthFailed extends AuthEvent {}

class AnonymousAuthRequested extends AuthEvent {}

class AccountCreationRequested extends AuthEvent {
  final String email;
  final String password;

  AccountCreationRequested({@required this.email, @required this.password});
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested({@required this.email, @required this.password});
}

class SignOutRequested extends AuthEvent {}

/// Encodes the status and data of results returned from our recipe API interface
abstract class AuthState {}

class Initializing extends AuthState {}

class Authenticated extends AuthState {}

class NotAuthenticated extends AuthState {}

class AuthInProgress extends AuthState {}

class AuthError extends AuthState {}

/// Connects our business logic with our UI code in an extensible way
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  FirebaseUser _currentUser;

  AuthBloc() {
    FirebaseAuth.instance.currentUser().then((user) {
      _currentUser = user;
      dispatch(AuthResult());
    }).catchError((error) {
      dispatch(AuthFailed());
    });
  }

  @override
  AuthState get initialState => Initializing();

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is AuthResult) {
      yield (_currentUser != null) ? Authenticated() : NotAuthenticated();
    }

    if (event is AnonymousAuthRequested) {
      yield AuthInProgress();
      try {
        var result = await FirebaseAuth.instance.signInAnonymously();
        _currentUser = result.user;
        yield Authenticated();
      } catch (error) {
        yield AuthError();
      }
    }

    if (event is SignInRequested) {
      yield AuthInProgress();
      try {
        var result = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        _currentUser = result.user;
        yield Authenticated();
      } catch (error) {
        yield AuthError();
      }
    }

    if (event is AccountCreationRequested) {
      yield AuthInProgress();
      try {
        var result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        _currentUser = result.user;
        yield Authenticated();
      } catch (error) {
        yield AuthError();
      }
    }

    if (event is SignOutRequested) {
      await FirebaseAuth.instance.signOut();
      _currentUser = null;
      yield NotAuthenticated();
    }

    if (event is AuthFailed) {
      yield AuthError();
    }
  }
}
