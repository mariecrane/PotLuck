import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PantryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: buildList(context),
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

buildList(BuildContext context) {
  return ListView.builder(
    key: PageStorageKey<String>("pantry_page"),
    shrinkWrap: true,
    itemBuilder: (context, index) {
      return (index < pantryList.length)
          ? IngredientsList(pantryList[index])
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120),
            );
    },
    itemCount: pantryList.length + 1,
  );
}

class IngredientsList extends StatelessWidget {
  final Pantry pantry;

  IngredientsList(this.pantry);

  @override
  Widget build(BuildContext context) {
    return _buildTiles(pantry);
  }

  Widget _buildTiles(Pantry p) {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      key: PageStorageKey<Pantry>(p),
      child: Column(
        children: [p.pantryContainer(p.inPantry)],)
    );
  }
}

class Pantry {
  String title;
  List<String> inPantry;

  Pantry(this.title, [this.inPantry = const <String>[]]);

  Widget pantryContainer(List<String> inP) {
    var pantryArea = new Wrap(
        spacing: 5.0,
        children: inP
            .map<Widget>((inG) => Container(
                    child: InputChip(
                  label: Text(inG),
                  onDeleted: () {},
                )))
            .toList());

    return pantryArea;
  }
}

List<Pantry> pantryList = <Pantry>[
  Pantry(
    'My Pantry',
    ["egg", "chicken", "spinach", "tofu", "onion", "turkey"],
  ),
];
