import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/pantry.dart';

class PantryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<PantryBloc, PantryState>(
        builder: (context, state) {
          if (state is PantryUpdated) {
            return IngredientsListView(state.pantry);
          }

          return CircularProgressIndicator();
        },
      ),
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
    );
  }
}
