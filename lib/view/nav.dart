import 'package:flutter/material.dart';
import 'package:pot_luck/view/pantry_page.dart';
import 'package:pot_luck/view/profile_page.dart';
import 'package:pot_luck/view/search_page.dart';

class NavWrapper extends StatefulWidget {
  @override
  _NavWrapperState createState() => _NavWrapperState();
}

class _NavWrapperState extends State<NavWrapper> {
  int _page = 2;

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
            title:
                Text('Pantry', style: TextStyle(color: _navColor(context, 0))),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.search, color: _navColor(context, 1)),
            title:
                Text('Search', style: TextStyle(color: _navColor(context, 1))),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.person, color: _navColor(context, 2)),
            title:
                Text('Profile', style: TextStyle(color: _navColor(context, 2))),
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
