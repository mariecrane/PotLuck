import 'package:flutter/material.dart';

class PantryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return ListView(
        key: PageStorageKey<String>("pantry_page"),
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            new Container(),
            Card(),
            Padding(),
            Padding(),
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
