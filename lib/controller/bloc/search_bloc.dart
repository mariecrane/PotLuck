import 'package:bloc/bloc.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/controller/search.dart';
import 'package:pot_luck/model/pantry.dart';
import 'package:pot_luck/model/recipe.dart';
import 'package:pot_luck/model/user.dart';

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

class _PantriesUpdated extends SearchEvent {
  final Pantry myPantry;
  final List<Pantry> friendPantries;

  _PantriesUpdated(this.myPantry, this.friendPantries);
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
  var _currentSearch = <PantryIngredient>[];
  // TODO: Remove modeled data after replacing with live data
//  List<PantryIngredient> _currentSearch = <PantryIngredient>[
//    PantryIngredient(
//      name: "cream cheese",
//      fromPantry: Pantry(
//        title: "Other",
//        owner: User(
//          name: "",
//          isNobody: true,
//        ),
//        ingredients: <PantryIngredient>[],
//      ),
//    ),
//  ];

  SearchBloc._privateConstructor() {
    DatabaseController.instance.onPantryUpdate((myPantry, friendPantries) {
      add(_PantriesUpdated(myPantry, friendPantries));
    });
  }
  // ignore: close_sinks
  static final instance = SearchBloc._privateConstructor();

  @override
  SearchState get initialState {
    if (_myPantry != null && _friendPantries != null) {
      return _makeBuildingSearchState();
    }
    return SearchLoading();
  }

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is _PantriesUpdated) {
      _myPantry = event.myPantry;
      _friendPantries = event.friendPantries;
      yield _makeBuildingSearchState();
    }

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

      if (_currentSearch.contains(ingredient)) return;

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
