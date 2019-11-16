import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/search.dart';
import 'package:pot_luck/ui/recipe_page.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          SearchBody(),
        ],
      ),
    );
  }

  static Widget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1.0,
      leading: Icon(Icons.search, color: Theme.of(context).primaryColor),
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
            hintText: "Add Ingredients",
          ),
          //TODO: change direct searching to adding the ingredients to the dropdown; bloc involved
          onSubmitted: (value) {
            BlocProvider.of<SearchBloc>(context).add(
              Submit(),
            );
          },
          onChanged: (value) {
            BlocProvider.of<SearchBloc>(context).add(
              QueryChange(value),
            );
          },
        ),
      ),
    );
  }

  static Widget buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add_shopping_cart),
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: () {
        Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => AddSearchIngredientsPage(),
        ));
      },
    );
  }
}

class SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: BlocBuilder<SearchBloc, SearchState>(
          /*
           * This function is called on every change in our app's state.
           * This allows us to show different UI depending on the status
           * of our search (not submitted, loading, finished, error).
           */
          builder: (context, state) {
            // Nothing has been searched yet; show tip/hint
            if (state is InitialState) {
              return PantryListView();
            }

            // In the progress of searching; show loading animation
            if (state is SearchInProgress) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            // Some error happened; display error message
            if (state is SearchError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            var results = (state as SearchSuccessful).results;
            if (results.length == 0) {
              return Center(
                child: Text(
                  "No recipes were found",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            // Search results returned; show formatted list of results
            return ListView.builder(
              key: PageStorageKey<String>("results_page"),
              itemCount: results.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return RecipeResult(results[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class PantryListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: PageStorageKey<String>("search_page"),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return (index < _pantryList.length)
            ? PantryTile(_pantryList[index])
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 120),
                child: RaisedButton(
                  onPressed: () {
                    //TODO: SEARCHHHHHH!!!!!
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0),
//            side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  textColor: Colors.white,
                  color: Theme.of(context).primaryColor,
                  child: const Text(
                    'Search',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              );
      },
      itemCount: _pantryList.length + 1,
    );
  }
}

class PantryTile extends StatelessWidget {
  final Pantry _pantry;
  PantryTile(this._pantry);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: PageStorageKey<Pantry>(_pantry),
      leading: Icon(Icons.shopping_basket),
      title: Text(_pantry.title),
      children: <Widget>[
        Wrap(
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
      ],
    );
  }
}

/// Simple data model for a single pantry with a title
class Pantry {
  final String title;
  final List<PantryIngredient> ingredients;

  Pantry(this.title, this.ingredients);
}

/// Simple data model for a single ingredient stored in a pantry
class PantryIngredient {
  final int id;
  final String name;
  final double amount;
  final String unit;

  PantryIngredient({this.id, this.name, this.amount, this.unit});
}

//TODO: this is hard-coded and very inefficient; ideally it changes depends on the friend but I cannot do anything about that now
List<Pantry> _pantryList = <Pantry>[
  Pantry(
    'All',
    <PantryIngredient>[
      PantryIngredient(name: "egg"),
      PantryIngredient(name: "cream cheese"),
      PantryIngredient(name: "chicken"),
      PantryIngredient(name: "garlic"),
      PantryIngredient(name: "apple"),
      PantryIngredient(name: "potato"),
      PantryIngredient(name: "tomato"),
      PantryIngredient(name: "basil"),
    ],
  ),
  Pantry(
    'My Pantry',
    <PantryIngredient>[
      PantryIngredient(name: "egg"),
      PantryIngredient(name: "chicken"),
    ],
  ),
  Pantry(
    'Shouayee Vue',
    <PantryIngredient>[
      PantryIngredient(name: "garlic"),
      PantryIngredient(name: "potato"),
    ],
  ),
  Pantry(
    'Preston Locke',
    <PantryIngredient>[
      PantryIngredient(name: "apple"),
    ],
  ),
  Pantry(
    'Tracy Cai',
    <PantryIngredient>[
      PantryIngredient(name: "tomato"),
    ],
  ),
  Pantry(
    'Marie Crane',
    <PantryIngredient>[
      PantryIngredient(name: "basil"),
    ],
  ),
  Pantry(
    'Others',
    <PantryIngredient>[
      PantryIngredient(name: "cream cheese"),
    ],
  ),
];

class RecipeResult extends StatelessWidget {
  final SearchResult data;

  RecipeResult(this.data);

  @override
  Widget build(BuildContext context) {
    // A container with rounded corners and a shadow by default
    return Card(
      color: Colors.white,
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: InkWell(
        splashColor: Colors.blueGrey[200],
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => RecipePage(data)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: SizedBox(
            height: 120.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(20.0),
                      child: Image(
                        image: NetworkImage(data.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //Recipe name and used ingredients
                      Text(
                        data.recipeName,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          // TODO: font change
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 5.0),
                      ),
                      Text(
                        "Uses: " + data.usedIngredients.toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.black54,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: FractionalOffset.bottomLeft,
                          child: Text(
                            data.likes.toString() + " LIKES",
                            style: const TextStyle(
                              fontSize: 13.0,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddSearchIngredientsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Search Ingredients"),
      ),
      body: ListView.builder(
        key: PageStorageKey<String>("search_ingredients_page"),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return (index < _pantryList.length)
              ? PantryTile(_pantryList[index])
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 120),
                  child: RaisedButton(
                    onPressed: () {
                      //TODO: Add ingredients to search (probably via bloc)
                      Navigator.of(context).pop();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20.0),
//            side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                    child: const Text(
                      'Add',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
        },
        itemCount: _pantryList.length + 1,
      ),
    );
  }
}
