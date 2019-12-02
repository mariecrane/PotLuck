import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/controller/bloc/pantry_bloc.dart';
import 'package:pot_luck/model/pantry.dart';

class PantryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<PantryBloc, PantryState>(
        builder: (context, state) {
          if (state is PantryUpdated) {
            return IngredientsListView(state.pantry);
          }

          if (state is SuggestingIngredients) {
            return _SuggestionListView(state.suggestions);
          }

          if (state is PantrySuggestionsEmpty) {
            return Center(
              child: Text(
                "No ingredients found",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }

  static Widget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1.0,
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
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: ListView(
        key: PageStorageKey<String>("pantry_page"),
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Ingredients in Your Pantry",
                  style: TextStyle(fontSize: 24.0)),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Wrap(
              runSpacing: 10,
              children: _pantry.ingredients
                  .map<Widget>(
                    (ingredient) => Container(
                      padding: EdgeInsets.all(5),
                      child: InputChip(
                        backgroundColor: Theme.of(context).primaryColor,
                        label: Text(ingredient.name, style:TextStyle(fontSize: 17.0, color: Colors.black, fontWeight: FontWeight.w400)),
                        onDeleted: () {
                          BlocProvider.of<PantryBloc>(context)
                              .add(PantryIngredientRemoved(ingredient));
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}

class _SuggestionListView extends StatelessWidget {
  final List<PantryIngredient> suggestions;

  const _SuggestionListView(this.suggestions, {Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return ListView.builder(
      key: PageStorageKey<String>("pantry_suggestion_page"),
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        var ingredient = suggestions[index];
        return ListTile(
          leading: Icon(Icons.add_shopping_cart),
          title: Text(ingredient.name),
          trailing: Icon(Icons.add),
          onTap: () {
            BlocProvider.of<PantryBloc>(context)
                .add(PantryIngredientAdded(ingredient));
          },
        );
      },
    );
  }
}
