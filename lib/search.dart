import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:pot_luck/friend.dart';
import 'package:pot_luck/pantry.dart';

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

class IngredientAdded extends SearchEvent {
  final PantryIngredient ingredient;
  IngredientAdded(this.ingredient);
}

class IngredientRemoved extends SearchEvent {
  final PantryIngredient ingredient;
  IngredientRemoved(this.ingredient);
}

class SearchCleared extends SearchEvent {}

class PantriesUpdated extends SearchEvent {
  final Pantry myPantry;
  final List<Pantry> friendPantries;

  PantriesUpdated(this.myPantry, this.friendPantries);
}

/// Encodes the status and data of results returned from our recipe API interface
abstract class SearchState {}

class BuildingSearch extends SearchState {
  final List<PantryIngredient> allIngredients;
  final List<Pantry> pantries;

  BuildingSearch({
    this.allIngredients = const <PantryIngredient>[],
    this.pantries = const <Pantry>[],
  });
}

class SearchLoading extends SearchState {}

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
  Pantry _myPantry;
  List<Pantry> _friendPantries;
  List<PantryIngredient> _currentSearch = <PantryIngredient>[
    PantryIngredient(
      name: "cream cheese",
      fromPantry: Pantry(
        title: "Other",
        owner: User(
          name: "",
          isNobody: true,
        ),
        ingredients: <PantryIngredient>[],
      ),
    ),
  ];

  SearchBloc() {
    var pf = PantryFetcher.instance;
    var futures = <Future>[
      pf.getMyPantry(),
      pf.getFriendPantries(),
    ];
    Future.wait(futures).then((results) {
      add(PantriesUpdated(results[0], results[1]));
      debugPrint("added PantriesUpdated event");
    });
    pf.onUpdate((myPantry, friendPantries) {
      add(PantriesUpdated(myPantry, friendPantries));
    });
  }

  @override
  SearchState get initialState {
    if (_myPantry != null && _friendPantries != null) {
      return _makeBuildingSearchState();
    }
    debugPrint("Returned SearchLoading from initialState");
    return SearchLoading();
  }

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is PantriesUpdated) {
      debugPrint("received PantriesUpdated event");
      _myPantry = event.myPantry;
      _friendPantries = event.friendPantries;
      yield _makeBuildingSearchState();
      return;
    }

    // TODO: Maybe yield loading state while fetching pantries
    _myPantry = await PantryFetcher.instance.getMyPantry();
    _friendPantries = await PantryFetcher.instance.getFriendPantries();

    if (event is SearchCleared) {
      _currentSearch.clear();
      yield _makeBuildingSearchState();
    }

    if (event is IngredientAdded) {
      var ingredient = event.ingredient;

      Pantry pantry;
      if (ingredient.fromPantry.owner.isMe) {
        pantry = _myPantry;
      } else {
        pantry = _friendPantries.firstWhere((p) => p == ingredient.fromPantry);
      }

      // Don't add to search if the ingredient isn't in friend's pantry anymore
      if (pantry.ingredients.contains(ingredient) == false) return;
      debugPrint("ingredient is still in pantry");

      if (_currentSearch.contains(ingredient)) return;
      debugPrint("search does not already contain ingredient");

      _currentSearch.add(ingredient);
      yield _makeBuildingSearchState();
    }

    if (event is IngredientRemoved) {
      if (_currentSearch.contains(event.ingredient)) {
        _currentSearch.remove(event.ingredient);
      }
      yield _makeBuildingSearchState();
    }

    // Commence a search if our user hit submit
    if (event is Submit) {
      if (_currentSearch.isNotEmpty) {
        // Let our UI know we're currently performing a search
        yield SearchLoading();

        try {
          // When our search returns results, pass them to the UI
          var results =
              await RecipeSearch.instance.getRecipeResults(_currentSearch);
          yield SearchSuccessful(results);
        } catch (error) {
          // TODO: Add more meaningful error messages
          yield SearchError(error.toString());
        }
      } else {
        // Nothing has been input; go back to initial state
        yield _makeBuildingSearchState();
      }
    }
  }

  BuildingSearch _makeBuildingSearchState() {
    _cleanSearch();
    var ingredients = _currentSearch.where((i) => i.fromPantry.owner.isNobody);

    var otherIngredients = Pantry(
      title: "Other",
      owner: User(
        name: "",
        isNobody: true,
      ),
      ingredients: <PantryIngredient>[],
    );

    ingredients.forEach((ingredient) {
      otherIngredients.ingredients.add(ingredient);
    });

    var friendPantries = <Pantry>[];
    _friendPantries.forEach((pantry) {
      friendPantries.add(pantry);
    });

    if (otherIngredients.ingredients.isNotEmpty) {
      friendPantries.add(otherIngredients);
    }

    var allPantries = <Pantry>[_myPantry];
    allPantries.addAll(friendPantries);

    return BuildingSearch(
      allIngredients: _currentSearch,
      pantries: allPantries,
    );
  }

  void _cleanSearch() {
    _currentSearch.removeWhere((ingredient) {
      if (ingredient.fromPantry.owner.isMe) {
        if (_myPantry.ingredients.contains(ingredient) == false) {
          return true;
        }
      } else if (ingredient.fromPantry.owner.isNobody == false) {
        var pantry =
            _friendPantries.firstWhere((p) => p == ingredient.fromPantry);
        if (pantry.ingredients.contains(ingredient) == false) {
          return true;
        }
      }
      return false;
    });
  }
}

class RecipeSearch {
  RecipeSearch._privateConstructor();
  static final RecipeSearch instance = RecipeSearch._privateConstructor();
  static final HttpsCallable recipesByIngredients =
      CloudFunctions.instance.getHttpsCallable(
    functionName: 'recipesByIngredients',
  );
  static final HttpsCallable recipeInfo =
      CloudFunctions.instance.getHttpsCallable(
    functionName: 'recipeInfo',
  );

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

  /// Fetches recipe results asynchronously
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
//      debugPrint(missedIngredients);
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
//      debugPrint(usedIngredients);
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

  /// Fetches detailed info for a single recipe asynchronously
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
