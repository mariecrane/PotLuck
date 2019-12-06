import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/controller/bloc/friend_bloc.dart';
import 'package:pot_luck/controller/bloc/search_bloc.dart';
import 'package:pot_luck/model/pantry.dart';
import 'package:pot_luck/model/recipe.dart';
import 'package:pot_luck/view/recipe_page.dart';

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
    return SearchAppBarWrapper();
  }

  static Widget buildFloatingActionButton(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchSuccessful) {
          return Container();
        }

        if (state is SearchLoading) {
          return Container();
        }

        return FloatingActionButton(
          child: Icon(Icons.group_add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => BlocProvider<FriendBloc>.value(
                  value: BlocProvider.of<FriendBloc>(context),
                  child: AddFriendPage(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class SearchAppBarWrapper extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchSuccessful) {
          return ResultsAppBar();
        }

        if (state is SearchLoading) {
          return Container();
        }

        return SearchAppBar();
      },
    );
  }

  // This is a shameless hack, but I can't think of a cleaner way...
  @override
  Size get preferredSize => AppBar().preferredSize;
}

class ResultsAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 1.0,
      leading: InkWell(
        child: Icon(Icons.arrow_back),
        onTap: () {
          BlocProvider.of<SearchBloc>(context).add(ResultsExited());
        },
      ),
      title: Text(
        "Search Results",
        style: TextStyle(fontFamily: 'MontserratScript'),
      ),
    );
  }
}

class SearchAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1.0,
      leading: Icon(Icons.add, color: Theme.of(context).primaryColor),
      title: Padding(
        // Adds some padding around our TextField
        padding: const EdgeInsets.symmetric(
          vertical: 5.0,
        ),
        child: TextField(
          // Type of "Done" button to show on keyboard
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
              border: InputBorder.none,
              // Shows when TextField is empty
              hintText: "Add Ingredients",
              hintStyle: TextStyle(fontFamily: 'MontserratScript')),
          onSubmitted: (value) {
            BlocProvider.of<SearchBloc>(context).add(SearchBarSubmitted());
          },
          onChanged: (value) {
            BlocProvider.of<SearchBloc>(context).add(SearchBarEdited(value));
          },
        ),
      ),
    );
  }
}

class AddFriendPage extends StatefulWidget {
  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  var _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add a Friend",
          style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w300,
              fontFamily: 'MontserratScript'),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Search for friends by email...",
                labelStyle: TextStyle(fontFamily: 'MontserratScript'),
              ),
            ),
          ),
          RaisedButton(
            elevation: 0.0,
            color: Colors.amber[100],
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0),
            ),
            child: Text(
              "Add",
              style: TextStyle(
                  fontSize: 17.0,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'MontserratScript'),
            ),
            onPressed: () {
              BlocProvider.of<FriendBloc>(context).add(
                FriendAddRequest(_controller.text),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            if (state is BuildingSearch) {
              return SearchListView(state.allIngredients, state.pantries);
            }

            if (state is SuggestingIngredient) {
              return _SuggestionListView(
                state.otherSuggestion,
                state.myPantrySuggestion,
                state.friendSuggestions,
              );
            }

            if (state is SuggestionsEmpty) {
              return Center(
                child: Text(
                  "No ingredients found",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            // In the progress of searching; show loading animation
            if (state is SearchLoading) {
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

class SearchListView extends StatelessWidget {
  final List<PantryIngredient> allIngredients;
  final List<Pantry> pantries;

  const SearchListView(this.allIngredients, this.pantries, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: PageStorageKey<String>("search_page"),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == 0) {
          return AllIngredientsTile(allIngredients);
        }
        return PantryTile(pantries[index - 1], allIngredients);
      },
      itemCount: pantries.length + 1,
    );
  }
}

class _SuggestionListView extends StatelessWidget {
  final PantryIngredient otherSuggestion;
  final PantryIngredient myPantrySuggestion;
  final List<PantryIngredient> friendSuggestions;

  const _SuggestionListView(
      this.otherSuggestion, this.myPantrySuggestion, this.friendSuggestions,
      {Key key})
      : super(key: key);

  Widget build(BuildContext context) {
    bool myPantryUsed = myPantrySuggestion != null;
    int count = friendSuggestions.length + (myPantryUsed ? 2 : 1);

    return ListView.builder(
      key: PageStorageKey<String>("search_suggestion_page"),
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        PantryIngredient ingredient;
        if (index == 0) {
          ingredient = otherSuggestion;
        } else if (myPantryUsed) {
          ingredient =
              index == 1 ? myPantrySuggestion : friendSuggestions[index - 2];
        } else {
          ingredient = friendSuggestions[index - 1];
        }

        // TODO: Differentiate Other, My Pantry, and friend pantry ingredients
        return ListTile(
          leading: Icon(Icons.add_shopping_cart),
          title: Text(ingredient.name + " in " + ingredient.fromPantry.title),
          trailing: Icon(Icons.add),
          onTap: () {
            BlocProvider.of<SearchBloc>(context)
                .add(IngredientAdded(ingredient));
          },
        );
      },
    );
  }
}

class AllIngredientsTile extends StatelessWidget {
  final List<PantryIngredient> ingredients;

  const AllIngredientsTile(this.ingredients, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Selected Ingredients",
                  style: TextStyle(fontSize: 24.0)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                child: Wrap(
                  spacing: 5.0,
                  children: ingredients
                      .map<Widget>(
                        (ingredient) => Container(
                          child: InputChip(
                            label: Text(
                              ingredient.name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300),
                            ),
                            deleteIconColor: Colors.white,
                            backgroundColor: ingredient.fromPantry.color,
                            onDeleted: () {
                              BlocProvider.of<SearchBloc>(context).add(
                                IngredientRemoved(ingredient),
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: RaisedButton(
                elevation: 0.0,
                onPressed: () {
                  BlocProvider.of<SearchBloc>(context).add(Submit());
                },
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                ),
                textColor: Colors.black,
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Text(
                    'Find Recipes',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.amber[100],
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PantryTile extends StatelessWidget {
  final Pantry _pantry;
  final List<PantryIngredient> _selectedIngredients;
  PantryTile(this._pantry, this._selectedIngredients);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(accentColor: _pantry.color),
      child: ExpansionTile(
        key: PageStorageKey<Pantry>(_pantry),
        //change it into profile picture
        leading: Icon(Icons.shopping_basket),
        title: Text(
          _pantry.title,
          style: TextStyle(color: _pantry.color, fontSize: 20.0),
        ),
//        Stack(
//          children: <Widget>[
//            Text(_pantry.title, style:TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold,
//              foreground: Paint()
//              ..style = PaintingStyle.stroke
//              ..strokeWidth = 0.5
//              ..color = Colors.black,)),
//            Text(_pantry.title, style:TextStyle(color: _pantry.color, fontSize: 20.0, fontWeight: FontWeight.bold)),
//          ],
//        ),
//        Text(_pantry.title,
//            style:TextStyle(color: _pantry.color, fontSize: 20.0, fontWeight: FontWeight.bold)),
        initiallyExpanded: false,
        children: <Widget>[
          Wrap(
            spacing: 5.0,
            children: _pantry.ingredients
                .map<Widget>(
                  (ingredient) => Container(
                    child: IngredientChip(
                      ingredient,
                      _selectedIngredients.contains(ingredient),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class IngredientChip extends StatelessWidget {
  final PantryIngredient ingredient;
  final bool isSelected;

  IngredientChip(this.ingredient, this.isSelected, {Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(brightness: Brightness.dark),
      child: FilterChip(
        label: Text(
          ingredient.name,
          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
        ),
        selected: isSelected,
        backgroundColor: Colors.blueGrey[200],
        onSelected: (_) {
          // Notify bloc of addition/removal
          BlocProvider.of<SearchBloc>(context).add(
            isSelected
                ? IngredientRemoved(ingredient)
                : IngredientAdded(ingredient),
          );
        },
        selectedColor: ingredient.fromPantry.color,
      ),
    );
  }
}

class RecipeResult extends StatelessWidget {
  final SearchResult data;

  RecipeResult(this.data);

  @override
  Widget build(BuildContext context) {
    // A container with rounded corners and a shadow by default
    return Card(
      color: Colors.white,
      elevation: 0.0,
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
                      borderRadius: new BorderRadius.circular(25.0),
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
