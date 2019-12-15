import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/controller/bloc/auth_bloc.dart';

/// Authors: Preston Locke, Shouayee Vue, Tracy Cai
/// auth_page.dart is the Authentication Page before a user logs into the App

/// The body of the Authentication page
class AuthPage extends StatefulWidget {
  final String errorMessage;

  AuthPage({this.errorMessage});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final key = GlobalKey<ScaffoldState>();
  int _currentForm = 0;

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      backgroundColor: Colors.white,
      key: key,
      body: SafeArea(
        child: WillPopScope(
            onWillPop: () async {
              if (_currentForm == 0) {
                return true;
              }
              setState(() {
                _currentForm = 0;
              });
              return false;
            },
            child: Center(
              child: _currentForm == 1
                  ? AuthForm(createAccount: false)
                  : _currentForm == 2
                      ? AuthForm(createAccount: true)
                      : _buildAuthChooser(),
            )),
      ),
    );
    return scaffold;
  }

  Widget _buildAuthChooser() {
    return ListView(
      children: <Widget>[
        Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Image.asset('assets/images/icon.png')),
        Padding(padding: EdgeInsets.symmetric(vertical: 20.0)),
        Center(
          child: Text.rich(
            TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text: 'Welcome to ',
                    style: TextStyle(
                        fontSize: 30, fontFamily: 'MontserratScript')),
                TextSpan(
                    text: 'PotLuck!',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontFamily: 'MontserratScript')),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 25.0,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 120.0),
          child: RaisedButton(
            elevation: 0.0,
            color: Colors.amber[100],
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0),
            ),
            child: Text("Sign in",
                style: TextStyle(
                    fontSize: 15.0,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'MontserratScript')),
            onPressed: () {
              setState(() {
                _currentForm = 1;
              });
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 100.0),
          child: RaisedButton(
            elevation: 0.0,
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0),
            ),
            child: Text("Create Account",
                style: TextStyle(
                    fontSize: 17.0,
                    color: Colors.amber[100],
                    fontWeight: FontWeight.w300,
                    fontFamily: 'MontserratScript')),
            onPressed: () {
              setState(() {
                _currentForm = 2;
              });
            },
          ),
        ),
      ],
    );
  }
}

/// The form used to enter in email and password
class AuthForm extends StatefulWidget {
  final createAccount;

  AuthForm({@required this.createAccount});

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
            ),
          ),
          Text("Please enter your Email and Password:",
              style: TextStyle(
                  fontSize: 17.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'MontserratScript')),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
            ),
          ),
          TextField(
            keyboardType: TextInputType.emailAddress,
            style:
                TextStyle(color: Colors.black, fontFamily: 'MontserratScript'),
            controller: _emailController,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Email",
                labelStyle: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontFamily: 'MontserratScript')),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
            ),
          ),
          TextField(
            keyboardType: TextInputType.visiblePassword,
            style:
                TextStyle(color: Colors.black, fontFamily: 'MontserratScript'),
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Password",
                labelStyle: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontFamily: 'MontserratScript')),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
            ),
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 80.0),
              child: RaisedButton(
                elevation: 0.0,
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                ),
                child: Text(widget.createAccount ? "Create account" : "Sign in",
                    style: TextStyle(
                        fontSize: 17.0,
                        color: Colors.amber[100],
                        fontWeight: FontWeight.w300,
                        fontFamily: 'MontserratScript')),
                onPressed: () {
                  // The event to dispatch to our AuthBloc
                  AuthEvent event;
                  if (widget.createAccount) {
                    event = AccountCreationRequested(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                  } else {
                    event = SignInRequested(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                  }
                  // Get reference to AuthBloc and dispatch event
                  BlocProvider.of<AuthBloc>(context).add(event);
                },
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
