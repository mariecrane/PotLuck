import 'dart:convert' as convert;

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Encodes all the data that is returned by our recipe API interface
// (Can be expanded later)
class SearchResult {
  final String recipeName;
  final int missedIngredients;
  final int matchedIngredients;

  SearchResult(
      {this.recipeName, this.missedIngredients, this.matchedIngredients});
}

// Encodes the type and data of events coming from our search UI
abstract class SearchEvent {}

class Submit extends SearchEvent {}

class QueryChange extends SearchEvent {
  final String searchString;
  QueryChange(this.searchString);
}

// Encodes the status and data of results returned from our recipe API interface
abstract class SearchState {}

class InitialState extends SearchState {}

class SearchInProgress extends SearchState {}

class SearchSuccessful extends SearchState {
  final List<SearchResult> results;
  SearchSuccessful(this.results);
}

// Connects our business logic with our UI code in an extensible way
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  String _searchString;

  @override
  SearchState get initialState => InitialState();

  // TODO: Add an error condition
  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    // Keep track of the current query
    if (event is QueryChange) {
      _searchString = event.searchString;
    }
    // Commence a search if our user hit submit
    if (event is Submit) {
      if (_searchString != "") {
        // Let our UI know we're currently performing a search
        yield SearchInProgress();

        // This is a horrible workaround but somehow the only working one to
        // get our SearchInProgress state to actually send
        // Hopefully unneeded when we put in real API calls?
        await Future.delayed(Duration(milliseconds: 100));

        // When our search returns results, pass them to the UI
        var results =
            await RecipeSearch.instance.getRecipeResults(_searchString);
        yield SearchSuccessful(results);
      } else {
        // Nothing has been input; go back to initial state
        yield InitialState();
      }
    }
  }
}

class RecipeSearch {
  RecipeSearch._privateConstructor();
  static final RecipeSearch instance = RecipeSearch._privateConstructor();

  final String _apiKey = "";

  String addParamsToUrl(String url, Map<String, dynamic> params) {
    if (params == null || params.length == 0) return url;

    url = "$url?apiKey=$_apiKey&";
    params.forEach((key, value) {
      // Insert key-value pairs into url parameter format
      url = "$url$key=$value&";
    });

    // Remove unnecessary trailing ampersand
    return url.substring(0, url.length - 2);
  }

  // Fetches recipe results
  Future<List<SearchResult>> getRecipeResults(String searchString) async {
    if (searchString.indexOf(",") == -1) searchString+=","; // fixes weird one search term bug //TODO: investigate further
    var url = addParamsToUrl(
      "https://api.spoonacular.com/recipes/findByIngredients",
      <String, dynamic>{"ingredients": searchString},
    );
    debugPrint(url);
    var response = await http.get(url);
    var data = convert.jsonDecode(response.body);

    var resultList = List<SearchResult>();

    data.forEach((result) {
      resultList.add(SearchResult(
        recipeName: result["title"],
        matchedIngredients: result["usedIngredientCount"],
        missedIngredients: result["missedIngredientCount"],
      ));
    });

    return resultList;

//    if (searchString == "ham,cheese") {
//      // TODO: Don't forget to remove artificial delay
//      await Future.delayed(Duration(seconds: 1));
//      return <SearchResult>[
//        SearchResult(recipeName: "Ham & Cheese Sandwich"),
//        SearchResult(recipeName: "Snack Crackers"),
//        SearchResult(recipeName: "Gourmet Crescent Rolls"),
//      ];
//    }
//    return List<SearchResult>();
  }
}
