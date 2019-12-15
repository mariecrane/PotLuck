import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:pot_luck/model/pantry.dart';
import 'package:pot_luck/model/recipe.dart';

/// Authors: Preston Locke, Marie Crane
/// This is the code that actually interfaces with the recipe and search-related
/// parts of our backend, including the recipesByIngredients, recipeInfo, and
/// autocomplete Cloud Functions

/// A singleton that implements all search-related functionality, including
/// ingredient auto-completion, recipe-by-ingredient search, and requests for
/// detailed info on specific recipes
class RecipeSearch {
  RecipeSearch._privateConstructor();

  /// A singleton of [RecipeSearch]
  static final RecipeSearch instance = RecipeSearch._privateConstructor();

  /// A reference to the recipesByIngredients cloud function used by
  /// [RecipeSearch]
  static final HttpsCallable recipesByIngredients =
      CloudFunctions.instance.getHttpsCallable(
    functionName: 'recipesByIngredients',
  );

  /// A reference to the recipesInfo cloud function used by [RecipeSearch]
  static final HttpsCallable recipeInfo =
      CloudFunctions.instance.getHttpsCallable(
    functionName: 'recipeInfo',
  );

  /// A reference to the autocomplete cloud function used by [RecipeSearch]
  static final HttpsCallable autocomplete =
      CloudFunctions.instance.getHttpsCallable(
    functionName: 'autocomplete',
  );

  /// Whether to use Metric or Imperial units
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

  Future<List<String>> getAutoSuggestions(String partial) async {
    var result = await autocomplete.call(<String, dynamic>{
      "query": partial,
    });
    try {
      List<dynamic> results = result.data;
      List<String> completions =
          results.map<String>((result) => result["name"]).toList();
      return completions;
    } catch (e) {
      debugPrint(e.toString());
      return <String>[];
    }
  }

  /// Fetches recipe results for the given query [search]
  Future<List<SearchResult>> getRecipeResults(
      List<PantryIngredient> search) async {
    var searchString = _ingredientsListToString(search);
    if (searchString.indexOf(",") == -1) searchString += ",";
    var unescape = HtmlUnescape();

    var response = await recipesByIngredients.call(<String, dynamic>{
      'ingredients': searchString,
    });

    var data = response.data;
    var resultList = List<SearchResult>();

    data.forEach((result) {
      var missedIngredients = "";
      for (var i = 0; i < result["missedIngredients"].length; i++) {
        // gets each missing ingredient and adds it to missedIngredients string
        missedIngredients += result["missedIngredients"][i]["name"] + ", ";
      }
      if (missedIngredients.length != 0) {
        // removes final comma
        missedIngredients =
            missedIngredients.substring(0, missedIngredients.length - 2);
      }
      var usedIngredients = "";
      for (var i = 0; i < result["usedIngredients"].length; i++) {
        // gets each matching ingredient and adds it to usedIngredients string
        usedIngredients += result["usedIngredients"][i]["name"] + ", ";
      }
      if (usedIngredients.length != 0) {
        // removes final comma
        usedIngredients =
            usedIngredients.substring(0, usedIngredients.length - 2);
      }
      resultList.add(SearchResult(
        result["id"],
        recipeName: unescape.convert(result["title"]),
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

  /// Fetches detailed info for [recipe]
  Future<RecipeInfo> getRecipeInfo(SearchResult recipe) async {
    var response = await recipeInfo.call(<String, dynamic>{
      'id': recipe.id,
    });

    var data = response.data;

    // Parse out the list of required ingredients
    var ingredients = List<RecipeIngredient>();
    bool useMetric = useMetricUnits;
    data["extendedIngredients"]?.forEach((ingredient) {
      // Get either US or Metric quantity values
      var measure = useMetric
          ? ingredient["measures"]["metric"]
          : ingredient["measures"]["us"];

      // Create a RecipeIngredient object with all of our parsed information
      ingredients.add(RecipeIngredient(
        id: ingredient["id"],
        name: ingredient["name"],
        amount: measure["amount"].toDouble(),
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

  String _ingredientsListToString(List<PantryIngredient> search) {
    var result = StringBuffer();
    for (int i = 0; i < search.length; i++) {
      result.write(search[i].name);
      if (i != search.length || search.length == 1) {
        result.write(",");
      }
    }
    return result.toString();
  }

//  /// Adds GET parameters to a url, also adding the API key automatically
//  Future<String> addParamsToUrl(String url, Map<String, dynamic> params) async {
//    // Fetch API key from our secrets file
//    var apiKey = convert.jsonDecode(
//        await rootBundle.loadString("assets/secrets.json"))["apiKey"];
//
//    // Always add API key as the first parameter in the URL
//    url = "$url?apiKey=$apiKey&";
//
//    if (params == null || params.length == 0) return url;
//
//    params.forEach((key, value) {
//      // Insert key-value pairs into url parameter format
//      url = "$url$key=$value&";
//    });
//
//    // Remove unnecessary trailing ampersand
//    return url.substring(0, url.length - 1);
//  }
}
