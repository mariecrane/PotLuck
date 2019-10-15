import 'dart:convert' as convert;

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Encodes all the data that is returned by our recipe API interface
/// (Can be expanded later)
class SearchResult {
  final int id;
  final String recipeName;
  final int missedIngredientCount;
  final int usedIngredientCount;
  final String missedIngredients;
  final String usedIngredients;
  final String imageUrl;
  final int likes;

  SearchResult(
    this.id, {
    this.recipeName,
    this.missedIngredientCount,
    this.usedIngredientCount,
    this.missedIngredients,
    this.usedIngredients,
    this.imageUrl,
    this.likes,
  });
}

/// Encodes the type and data of events coming from our search UI
abstract class SearchEvent {}

class Submit extends SearchEvent {}

class QueryChange extends SearchEvent {
  final String searchString;
  QueryChange(this.searchString);
}

/// Encodes the status and data of results returned from our recipe API interface
abstract class SearchState {}

class InitialState extends SearchState {}

class SearchInProgress extends SearchState {}

class SearchSuccessful extends SearchState {
  final List<SearchResult> results;
  SearchSuccessful(this.results);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

/// Connects our business logic with our UI code in an extensible way
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  String _searchString;
  String _lastSearch;

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
      // Don't submit if the search didn't actually change
      if (_searchString == _lastSearch) return;

      if (_searchString != "") {
        // Let our UI know we're currently performing a search
        yield SearchInProgress();

        // This is a horrible workaround but somehow the only working one to
        // get our SearchInProgress state to actually send
        // Hopefully unneeded when we put in real API calls?
        // Update: seems unnecessary now, but for safety, we'll keep this around
        // await Future.delayed(Duration(milliseconds: 100));

        try {
          // When our search returns results, pass them to the UI
          var results =
              await RecipeSearch.instance.getRecipeResults(_searchString);
          yield SearchSuccessful(results);
        } catch (error) {
          // TODO: Add more meaningful error messages
          yield SearchError(error.toString());
        }
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

  final String _apiKey = ""; // REMEMBER TO ADD AND REMOVE API KEY!!!

  bool get useMetricUnits {
    // TODO: Add logic to determine whether we should use US or Metric units
    // (Could also maybe fetch this from app settings in the future...)
    return false;
  }

  /// Builds the full URL for an image of an ingredient
  String ingredientImageUrl(String fileName) {
    // TODO: Add some way to pick the image size? (Choices are 100, 250, 500)
    String size = "250x250";
    return "https://spoonacular.com/cdn/ingredients_$size/$fileName";
  }

  /// Adds GET parameters to a url, also adding the API key automatically
  String addParamsToUrl(String url, Map<String, dynamic> params) {
    // Always add API key as the first parameter in the URL
    url = "$url?apiKey=$_apiKey&";

    if (params == null || params.length == 0) return url;

    params.forEach((key, value) {
      // Insert key-value pairs into url parameter format
      url = "$url$key=$value&";
    });

    // Remove unnecessary trailing ampersand
    return url.substring(0, url.length - 1);
  }

  /// Fetches recipe results asynchronously
  Future<List<SearchResult>> getRecipeResults(String searchString) async {
    // TODO: investigate further
    // Fixes weird one search term bug
    if (searchString.indexOf(",") == -1) searchString += ",";
    var url = addParamsToUrl(
      "https://api.spoonacular.com/recipes/findByIngredients",
      <String, dynamic>{"ingredients": searchString},
    );
    debugPrint(url);
    var response = await http.get(url);
    debugPrint(response.body);
    var data = convert.jsonDecode(response.body);

    var resultList = List<SearchResult>();

    data.forEach((result) {
      var missedIngredients = "";
      for (var i = 0; i < result["missedIngredients"].length; i++) {
        // gets each missing ingredient and adds it to missedIngredients string
        missedIngredients += result["missedIngredients"][i]["name"] + ", ";
        //TODO: implement "+6 more"
      }
      if (missedIngredients.length != 0) {
        // removes final comma
        missedIngredients =
            missedIngredients.substring(0, missedIngredients.length - 2);
      }
      debugPrint(missedIngredients);
      var usedIngredients = "";
      for (var i = 0; i < result["usedIngredients"].length; i++) {
        // gets each matching ingredient and adds it to usedIngredients string
        usedIngredients += result["usedIngredients"][i]["name"] + ", ";
        //TODO: implement "+6 more"
      }
      if (usedIngredients.length != 0) {
        // removes final comma
        usedIngredients =
            usedIngredients.substring(0, usedIngredients.length - 2);
      }
      debugPrint(usedIngredients);
      resultList.add(SearchResult(
        result["id"],
        recipeName: result["title"],
        usedIngredientCount: result["usedIngredientCount"],
        missedIngredientCount: result["missedIngredientCount"],
        missedIngredients: missedIngredients,
        usedIngredients: usedIngredients,
        imageUrl: result["image"],
        likes: result["likes"],
      ));
    });
    return resultList;
  }

  /// Fetches detailed info for a single recipe asynchronously
  Future<RecipeInfo> getRecipeInfo(SearchResult recipe) async {
    // We call addParamsToURL to add the api key to the URL
    var url = addParamsToUrl(
        "https://api.spoonacular.com/recipes/${recipe.id}/information", {});
    debugPrint(url);

    // Get the API response, formatted as a JSON object
    var response = await http.get(url);
    var data = convert.jsonDecode(response.body);

    // Parse out the list of required ingredients
    var ingredients = List<RecipeIngredient>();
    bool useMetric = useMetricUnits;
    data["extendedIngredients"].forEach((ingredient) {
      // Get either US or Metric quantity values
      var measure = useMetric
          ? ingredient["measures"]["metric"]
          : ingredient["measures"]["us"];

      // Create a RecipeIngredient object with all of our parsed information
      ingredients.add(RecipeIngredient(
        id: ingredient["id"],
        name: ingredient["name"],
        amount: measure["amount"],
        unit: measure["unitShort"],
        imageUrl: ingredientImageUrl(ingredient["image"]),
      ));
    });

    // TODO: Handle multiple sets of instructions (prerequisite ingredients)
    // Parse out the list of steps
    var steps = List<RecipeStep>();
    if (data["analyzedInstructions"].length != 0) {
      data["analyzedInstructions"][0]["steps"].forEach((instruction) {
        steps.add(RecipeStep(
          instructionsText: instruction["step"],
        ));
      });
    }

    return RecipeInfo(
      id: data["id"],
      title: data["title"],
      imageUrl: data["image"],
      sourceUrl: data["sourceUrl"],
      creditsText: data["creditsText"],
      ingredients: ingredients,
      steps: steps,
    );
  }
}

/// Models the available info about a single recipe
class RecipeInfo {
  final int id;
  final String title;
  final String imageUrl;
  final String sourceUrl;
  final String creditsText;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;

  RecipeInfo(
      {this.id,
      this.title,
      this.imageUrl,
      this.sourceUrl,
      this.creditsText,
      this.ingredients,
      this.steps});
}

/// Models a single step of instructions for a single recipe
class RecipeStep {
  final String instructionsText;

  RecipeStep({this.instructionsText});
}

/// Models a single ingredient necessary for a specific recipe, including the
/// amount needed
class RecipeIngredient {
  final int id;
  final String name;
  final double amount;
  final String unit;
  final String imageUrl;

  RecipeIngredient({this.id, this.name, this.amount, this.unit, this.imageUrl});
}
