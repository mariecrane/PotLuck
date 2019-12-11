import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/controller/bloc/auth_bloc.dart';
import 'package:pot_luck/controller/bloc/friend_bloc.dart';
import 'package:pot_luck/controller/bloc/friend_requests_bloc.dart';
import 'package:pot_luck/controller/bloc/pantry_bloc.dart';
import 'package:pot_luck/controller/bloc/profile_bloc.dart';
import 'package:pot_luck/controller/bloc/search_bloc.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/view/auth_page.dart';
import 'package:pot_luck/view/nav.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

const _primaryColor = <int, Color>{
  50: Color.fromRGBO(242, 180, 105, 1),
  100: Color.fromRGBO(240, 171, 86, 1),
  200: Color.fromRGBO(239, 162, 67, 1),
  300: Color.fromRGBO(237, 152, 49, 1),
  400: Color.fromRGBO(235, 143, 30, 1),
  500: Color.fromRGBO(226, 132, 19, 1),
  600: Color.fromRGBO(206, 122, 18, 1),
  700: Color.fromRGBO(188, 111, 16, 1),
  800: Color.fromRGBO(169, 100, 15, 1),
  900: Color.fromRGBO(150, 88, 13, 1),
};
const _primarySwatch = MaterialColor(0xffe28413, _primaryColor);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "PotLuck",
      theme: ThemeData(
        primarySwatch: _primarySwatch,
      ),
      // Update based on authentication state
      home: Provider<DatabaseController>(
        create: (_) => DatabaseController.instance,
        dispose: (_, controller) => controller.dispose(),
        child: MultiBlocProvider(
          providers: <BlocProvider>[
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(),
            ),
            BlocProvider<SearchBloc>(
              create: (context) => SearchBloc(),
            ),
            BlocProvider<PantryBloc>(
              create: (context) => PantryBloc(),
            ),
            BlocProvider<FriendsListBloc>(
              create: (context) => FriendsListBloc(),
            ),
            BlocProvider<FriendRequestsBloc>(
              create: (context) => FriendRequestsBloc(),
            ),
            BlocProvider<ProfileBloc>(
              create: (context) => ProfileBloc(),
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
      ),
    );
  }
}
