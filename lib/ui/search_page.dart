import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/auth.dart';
import 'package:pot_luck/search.dart';
import 'package:pot_luck/ui/recipe_page.dart';

class SearchPage extends StatelessWidget {
  final String title;

  SearchPage({this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      // TODO: Put the sign out function somewhere that actually makes sense
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.close),
        onPressed: () {
          BlocProvider.of<AuthBloc>(context).dispatch(SignOutRequested());
        },
      ),
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
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1.0,
      leading: Icon(Icons.search, color: Colors.blueGrey[300]),
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
        color: Colors.white,
        elevation: 1.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
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
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
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
                        )
                      ]))),
        ));
  }
}
