import 'package:flutter/material.dart';

class PantryPage extends StatelessWidget {
  @override
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

  String dropdownValue1 = 'All Ingredients';
  String dropdownValue2 = 'Proteins';
  String dropdownValue3 = 'Vegetables';
  String dropdownValue4 = 'Fruits';
  String dropdownValue5 = 'Other';
  Widget build(BuildContext context) {
    return ListView(
              children: ListTile.divideTiles(
              context: context,
              tiles: [
                DropdownButton<String>(
                  value: dropdownValue1,
                  icon: Icon(Icons.arrow_downward, color: Theme
                      .of(context)
                      .primaryColor),
                  iconSize: 24,
                  elevation: 0,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Theme
                          .of(context)
                          .primaryColor
                  ),
                  underline: Container(
                    height: 4,
                    color: Theme
                        .of(context)
                        .primaryColor,
                  ),
                  onChanged: (String newValue) {
                    dropdownValue1 = newValue;
                  },
                  items: <String>[
                    'All Ingredients',
                    'Chicken',
                    'Beef',
                    'Lettuce',
                    'Peas',
                    'Orange',
                    'Apple',
                    'Flour',
                    'Cheetos',]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  })
                      .toList(),
                ),
                DropdownButton<String>(
                  value: dropdownValue2,
                  icon: Icon(Icons.arrow_downward, color: Colors.pink),
                  iconSize: 24,
                  elevation: 0,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.pink
                  ),
                  underline: Container(
                    height: 4,
                    color: Colors.pink,
                  ),
                  onChanged: (String newValue) {
                    dropdownValue2 = newValue;
                  },
                  items: <String>[
                    'Proteins',
                    'Chicken',
                    'Beef']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  })
                      .toList(),
                ),
                DropdownButton<String>(
                  value: dropdownValue3,
                  icon: Icon(Icons.arrow_downward, color: Colors.green),
                  iconSize: 24,
                  elevation: 0,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.green
                  ),
                  underline: Container(
                    height: 4,
                    color: Colors.green,
                  ),
                  onChanged: (String newValue) {
                    dropdownValue3 = newValue;
                  },
                  items: <String>[
                    'Vegetables',
                    'Lettuce',
                    'Peas']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  })
                      .toList(),
                ),
                DropdownButton<String>(
                  value: dropdownValue4,
                  icon: Icon(Icons.arrow_downward, color: Colors.purple),
                  iconSize: 24,
                  elevation: 0,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.purple
                  ),
                  underline: Container(
                    height: 4,
                    color: Colors.purple,
                  ),
                  onChanged: (String newValue) {
                    dropdownValue4 = newValue;
                  },
                  items: <String>[
                    'Fruits',
                    'Apple',
                    'Orange']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  })
                      .toList(),
                ),
                DropdownButton<String>(
                  value: dropdownValue5,
                  icon: Icon(Icons.arrow_downward, color: Colors.black),
                  iconSize: 24,
                  elevation: 0,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black
                  ),
                  underline: Container(
                    height: 4,
                    color: Colors.black
                  ),
                  onChanged: (String newValue) {
                    dropdownValue5 = newValue;
                  },
                  items: <String>[
                    'Other',
                    'Flour',
                    'Cheetos']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  })
                      .toList(),
                ),
              ],
            ).toList(),
          );
  }

  static Widget buildFloatingActionButton(BuildContext context) {
    return null;
  }
}
