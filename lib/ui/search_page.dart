import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/search.dart';
import 'package:pot_luck/ui/recipe_page.dart';

class SearchPage extends StatelessWidget {
  final String title;

  SearchPage({this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          builder: (context) => SearchBloc(),
          child: Column(
            children: <Widget>[
              SearchBar(),
              SearchBody(),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Just a type of container that has certain properties we can use
    return Material(
      // Controls how large of a shadow this should have
      elevation: 3.0,
      child: Padding(
        // Adds some padding around our TextField
        padding: const EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 15.0,
        ),
        child: TextField(
          // Type of "Done" button to show on keyboard
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            border: InputBorder.none,
            // Shows when TextField is empty
            hintText: "Search Ingredients",
          ),
          onSubmitted: (value) {
            BlocProvider.of<SearchBloc>(context).dispatch(
              Submit(),
//              SearchEvent(value, submitted: true),
            );
          },
          onChanged: (value) {
            BlocProvider.of<SearchBloc>(context).dispatch(
              QueryChange(value),
            );
          },
        ),
      ),
    );
  }
}

class SearchBody extends StatelessWidget {
  final SliverGridDelegate _gridDelegate;
//TODO: vfffff
  SearchBody()
      : _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
          // This is how many results we want in one row
          crossAxisCount: 2,

          // This is the vertical spacing between our results
          mainAxisSpacing: 5.0,

          // This is the horizontal spacing between our results
          crossAxisSpacing: 5.0,
        );

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
              return Center(
                child: Text(
                  "Please enter your available ingredients",
                  style: TextStyle(color: Colors.grey),
                ),
              );
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
//            return GridView.builder(
//              // See above for explanation of this
//              gridDelegate: _gridDelegate,
//              itemCount: results.length,
//              /*
//                       * This function is called once for each grid item created.
//                       * This allows us to build items dynamically as the user
//                       * scrolls, using the index to know which item we're on.
//                       */
//              itemBuilder: (context, index) {
//                return RecipeResult(results[index]);
//              },
//            );
            // TODO: LIST VIEW
            return ListView.builder(
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

class RecipeResult extends StatelessWidget {
  final SearchResult data;

  RecipeResult(this.data);

  @override
  Widget build(BuildContext context) {
    // A container with rounded corners and a shadow by default
    return Card(
      color: Colors.deepOrange[50],
      elevation: 2.0,
      shape: RoundedRectangleBorder(),
      // Lay out our item as a square with header, footer, body
      child: ListTile(
        //Image should be shown
        // TODO: change it to real
//        leading: Icon(Icons.fastfood),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(data.imageUrl),
        ),
        title: Text(data.recipeName),
        subtitle: Text("Use: " + data.usedIngredients.toString()),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => RecipePage(data)),
          );
        },
      ),
    );

//    return Card(
//      color: Colors.red[300],
//      elevation: 2.0,
//      // Lay out our item as a square with header, footer, body
//      child: GridTile(
//        // Multiline header/footer designed for use in GridTile
//        header: GridTileBar(
//          backgroundColor: Color.fromARGB(64, 255, 255, 255),
//          title: Text(data.recipeName),
//          subtitle:
//          Text(data.matchedIngredients.toString() + " Matched Ingredients"),
//        ),
//        footer: GridTileBar(
//          backgroundColor: Color.fromARGB(64, 127, 127, 127),
//          title:
//          Text(data.missedIngredients.toString() + " Missing Ingredients"),
//          subtitle: Text("Missing Ingredients List"),
//        ),
//        // This could be a thumbnail for our recipe result later
//        child: Center(
//          child: FlutterLogo(),
//        ),
//      ),
//    );
  }
}
