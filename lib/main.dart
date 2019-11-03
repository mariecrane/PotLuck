import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/auth.dart';
import 'package:pot_luck/ui/auth_page.dart';

import 'ui/search_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "PotLuck",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Update based on authentication state
      home: BlocProvider(
        builder: (context) => AuthBloc(),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Initializing) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is AuthInProgress) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is Authenticated) {
              return SearchPage(title: "PotLuck Search Page");
            }

            if (state is NotAuthenticated) {
              return AuthPage();
            }

            return AuthPage(errorMessage: "Failed to authenticate");
          },
        ),
      ),
    );
  }
}
