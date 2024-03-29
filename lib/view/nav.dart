import 'package:flutter/material.dart';
import 'package:pot_luck/view/pantry_page.dart';
import 'package:pot_luck/view/profile_page.dart';
import 'package:pot_luck/view/search_page.dart';

/// Authors: Preston Locke, Shouayee Vue, Tracy Cai
/// nav.dart is the Navigation that connects all the pages in the view folder together.

class NavWrapper extends StatefulWidget {
  @override
  _NavWrapperState createState() => _NavWrapperState();
}

/// Wraps the pages in a [Scaffold] and displays a [BottomNavigationBar]
class _NavWrapperState extends State<NavWrapper> {
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: _currentAppBar(context),
      body: _currentPage(context),
      floatingActionButton: _currentButton(context),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() {
          _page = index;
        }),
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.dehaze, color: _navColor(context, 0)),
            title: Text(
              'Pantry',
              style: TextStyle(
                  color: _navColor(context, 0),
                  fontSize: 17.0,
                  fontFamily: 'MontserratScript',
                  fontWeight: FontWeight.w200),
            ),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.search, color: _navColor(context, 1)),
            title: Text(
              'Search',
              style: TextStyle(
                  color: _navColor(context, 1),
                  fontSize: 17.0,
                  fontFamily: 'MontserratScript',
                  fontWeight: FontWeight.w200),
            ),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.person, color: _navColor(context, 2)),
            title: Text(
              'Profile',
              style: TextStyle(
                  color: _navColor(context, 2),
                  fontSize: 17.0,
                  fontFamily: 'MontserratScript',
                  fontWeight: FontWeight.w200),
            ),
          )
        ],
      ),
    );
  }

  Widget _currentAppBar(BuildContext context) {
    switch (_page) {
      case 0:
        return PantryPage.buildAppBar(context);
      case 1:
        return SearchPage.buildAppBar(context);
      default:
        return ProfilePage.buildAppBar(context);
    }
  }

  Widget _currentPage(BuildContext context) {
    switch (_page) {
      case 0:
        return PantryPage();
      case 1:
        return SearchPage();
      default:
        return ProfilePage();
    }
  }

  Widget _currentButton(BuildContext context) {
    switch (_page) {
      case 0:
        return PantryPage.buildFloatingActionButton(context);
      case 1:
        return SearchPage.buildFloatingActionButton(context);
      default:
        return ProfilePage.buildFloatingActionButton(context);
    }
  }

  Color _navColor(BuildContext context, int page) {
    if (_page == page) {
      return Theme.of(context).primaryColor;
    }
    return Colors.black;
  }
}
