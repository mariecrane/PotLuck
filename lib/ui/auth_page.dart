import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/auth.dart';

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
          // Allow back button to trigger a return to AuthChooser before exiting app
            onWillPop: () async {
              // If already/still on AuthChooser, do default back button behavior
              if (_currentForm == 0) {
                return true;
              }
              // Back out of SignInForm/CreateAccountForm and display AuthChooser
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

//    key.currentState.showSnackBar(SnackBar(
//      content: Text(widget.errorMessage),
//      duration: Duration(seconds: 2),
//    ));

    return scaffold;
  }

  Widget _buildAuthChooser() {
    return Column(
      children: <Widget>[
        Image.asset('assets/images/icon.png'),
        Text.rich(
          TextSpan(
            children: <TextSpan>[
              TextSpan(text: 'Welcome to ',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              TextSpan(
                  text: 'PotLuck!',
                  style: TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold, color: Theme
                      .of(context)
                      .primaryColor)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 25.0,
          ),
        ),
        RaisedButton(
          color: Colors.yellow,
          child: Text("Sign in"),
          onPressed: () {
            setState(() {
              _currentForm = 1;
            });
          },
        ),
        RaisedButton(
          color: Colors.yellow,
          child: Text("Create Account"),
          onPressed: () {
            setState(() {
              _currentForm = 2;
            });
          },
        ),
        FlatButton(
          child: Text("Sign in later", style: TextStyle(color: Theme
              .of(context)
              .primaryColor)),
          onPressed: () {
            // Request BLoC to do anonymous login
            BlocProvider.of<AuthBloc>(context).add(AnonymousAuthRequested());
          },
        ),
      ],
    );
  }
}

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
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
            ),
          ),
          Text("Please enter your Email and Password:"),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
            ),
          ),
          TextField(
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Email"),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
            ),
          ),
          TextField(
            keyboardType: TextInputType.visiblePassword,
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Password"),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
            ),
          ),
          RaisedButton(
            color: Colors.yellow,
            child: Text(widget.createAccount ? "Create account" : "Sign in"),
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
          )
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
