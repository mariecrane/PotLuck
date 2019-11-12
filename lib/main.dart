import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/auth.dart';
import 'package:pot_luck/friend.dart';
import 'package:pot_luck/search.dart';
import 'package:pot_luck/ui/auth_page.dart';
import 'package:pot_luck/ui/nav.dart';

void main() => runApp(MyApp());

Map<int, Color> color = {
  50: Color.fromRGBO(226, 132, 19, .1),
  100: Color.fromRGBO(226, 132, 19, .2),
  200: Color.fromRGBO(226, 132, 19, .3),
  300: Color.fromRGBO(226, 132, 19, .4),
  400: Color.fromRGBO(226, 132, 19, .5),
  500: Color.fromRGBO(226, 132, 19, .6),
  600: Color.fromRGBO(226, 132, 19, .7),
  700: Color.fromRGBO(226, 132, 19, .8),
  800: Color.fromRGBO(226, 132, 19, .9),
  900: Color.fromRGBO(226, 132, 19, 1),
};
MaterialColor myColor = MaterialColor(0xffe28413, color);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "PotLuck",
      theme: ThemeData(
        primarySwatch: myColor,
      ),
      // Update based on authentication state
      home: MultiBlocProvider(
        providers: <BlocProvider>[
          BlocProvider<AuthBloc>(
            builder: (context) => AuthBloc(),
          ),
          BlocProvider<SearchBloc>(
            builder: (context) => SearchBloc(),
          ),
          BlocProvider<FriendBloc>(
            builder: (context) => FriendBloc(),
          ),
        ],
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
              return NavWrapper();
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
