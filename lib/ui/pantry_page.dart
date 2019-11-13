import 'package:flutter/material.dart';

class PantryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return ListView(
        key: PageStorageKey<String>("pantry_page"),
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Container(
                child: ListTile(
                  //TODO: replace dummy data with data from user's account on database
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 10.0,
                  ),
                  title: Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('Username: @jdoe\nEmail: jdoe@hotmail.com'),
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin: EdgeInsets.all(10),
            ),
          ],
        ).toList(),
      );
    }

  static Widget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: true,
      title: Padding(
        // Adds some padding around our TextField
        padding: const EdgeInsets.symmetric(
          vertical: 5.0,
        ),
        child: TextField(
          // Type of "Done" button to show on keyboard
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            border: InputBorder.none,
            // Shows when TextField is empty
            hintText: "Add Ingredients to Pantry...",
          ),
          onSubmitted: (value) {},
          onChanged: (value) {},
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.add, color: Theme
            .of(context)
            .primaryColor),
      ),
    );
  }

  static Widget buildFloatingActionButton(BuildContext context) {
    return null;
  }
}
