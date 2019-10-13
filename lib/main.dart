import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'search.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PotLuck',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'PotLuck Search Page'),
    );
  }
}

class HomePage extends StatelessWidget {
  final String title;

  HomePage({this.title});

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

            // TODO: Add an error condition

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
            return GridView.builder(
              // See above for explanation of this
              gridDelegate: _gridDelegate,
              itemCount: results.length,
              /*
                       * This function is called once for each grid item created.
                       * This allows us to build items dynamically as the user
                       * scrolls, using the index to know which item we're on.
                       */
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
      color: Colors.red[300],
      elevation: 2.0,
      // Lay out our item as a square with header, footer, body
      child: GridTile(
        // Multiline header/footer designed for use in GridTile
        header: GridTileBar(
          backgroundColor: Color.fromARGB(64, 255, 255, 255),
          title: Text(data.recipeName),
          subtitle:
              Text(data.usedIngredients),
        ),
        footer: GridTileBar(
          backgroundColor: Color.fromARGB(64, 127, 127, 127),
          title:
              Text(data.missedIngredientCount.toString() + " Missing Ingredients"),
          subtitle: Text(data.missedIngredients),
        ),
        // This could be a thumbnail for our recipe result later
        child: Center(
          child: FlutterLogo(),
        ),
      ),
    );
  }
}
