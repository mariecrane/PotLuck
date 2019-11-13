import 'package:flutter/material.dart';

class PantryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: ListView.builder(
      ),
    );
  }

  static Widget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1.0,
      title: Text(
        "Your Pantry",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme
              .of(context)
              .primaryColor,
          fontSize: 28,
        ),
      ),
    );
  }

  static Widget buildFloatingActionButton
      (BuildContext context) {
    return null;
  }
}
