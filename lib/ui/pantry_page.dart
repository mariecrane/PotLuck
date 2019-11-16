import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pot_luck/ui/search_page.dart';

class PantryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IngredientsListView(_pantry),
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
        icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
      ),
    );
  }

  static Widget buildFloatingActionButton(BuildContext context) {
    return null;
  }
}

class IngredientsListView extends StatelessWidget {
  final Pantry _pantry;

  IngredientsListView(this._pantry);

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: PageStorageKey<String>("pantry_page"),
      children: <Widget>[
        Card(
          child: Wrap(
            spacing: 5.0,
            children: _pantry.ingredients
                .map<Widget>(
                  (ingredient) => Container(
                    child: InputChip(
                      label: Text(ingredient.name),
                      onDeleted: () {
                        //TODO: actually delete the chip: will it be too small?
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        )
      ],
    );
  }
}

Pantry _pantry = Pantry(
  'My Pantry',
  [
    PantryIngredient(name: "egg"),
    PantryIngredient(name: "chicken"),
    PantryIngredient(name: "spinach"),
    PantryIngredient(name: "tofu"),
    PantryIngredient(name: "onion"),
    PantryIngredient(name: "turkey"),
  ],
);
