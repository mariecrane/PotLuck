import 'package:flutter/material.dart';
import 'package:pot_luck/ui/favorite_page.dart';
import 'package:pot_luck/ui/friend_page.dart';
import 'package:pot_luck/ui/pantry_page.dart';
import 'package:pot_luck/ui/profile_page.dart';
import 'package:pot_luck/ui/search_page.dart';

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
            icon: Icon(Icons.favorite, color: _navColor(context, 1)),
            title: Text('Favorites',
                style: TextStyle(color: _navColor(context, 1))),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.search, color: _navColor(context, 2)),
            title:
                Text('Search', style: TextStyle(color: _navColor(context, 2))),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.group, color: _navColor(context, 3)),
            title:
                Text('Friends', style: TextStyle(color: _navColor(context, 3))),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.person, color: _navColor(context, 4)),
            title:
                Text('Profile', style: TextStyle(color: _navColor(context, 4))),
          )
        ],
      ),
    );
  }

  _currentAppBar(BuildContext context) {
    switch (_page) {
      case 0:
        return PantryPage.buildAppBar(context);
      case 1:
        return FavoritePage.buildAppBar(context);
      case 2:
        return SearchPage.buildAppBar(context);
      case 3:
        return FriendPage.buildAppBar(context);
      default:
        return ProfilePage.buildAppBar(context);
    }
  }

  Widget _currentPage(BuildContext context) {
    switch (_page) {
      case 0:
        return PantryPage(Colors.white);
      case 1:
        return FavoritePage(Colors.white);
      case 2:
        return SearchPage();
      case 3:
        return FriendPage(Colors.white);
      default:
        return ProfilePage(Colors.white);
    }
  }

  Color _navColor(BuildContext context, int page) {
    if (_page == page) {
      return Theme.of(context).primaryColor;
    }
    return Colors.black;
  }
}
