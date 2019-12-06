import 'package:bloc/bloc.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/controller/search.dart';
import 'package:pot_luck/model/pantry.dart';
import 'package:pot_luck/model/recipe.dart';
import 'package:pot_luck/model/user.dart';

/// Encodes the type and data of events coming from our search UI
abstract class SearchEvent {}

class SearchBarEdited extends SearchEvent {
  final String text;

  SearchBarEdited(this.text);
}

class SearchBarSubmitted extends SearchEvent {}

class Submit extends SearchEvent {}

class IngredientAdded extends SearchEvent {
  final PantryIngredient ingredient;

  IngredientAdded(this.ingredient);
}

class IngredientRemoved extends SearchEvent {
  final PantryIngredient ingredient;

  IngredientRemoved(this.ingredient);
}

class ResultsExited extends SearchEvent {}

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

class SuggestingIngredient extends SearchState {
  final PantryIngredient otherSuggestion;
  final PantryIngredient myPantrySuggestion;
  final List<PantryIngredient> friendSuggestions;

  SuggestingIngredient(
      this.otherSuggestion, this.myPantrySuggestion, this.friendSuggestions);
}

class SuggestionsEmpty extends SearchState {}

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
  String _barText = "";
  bool _showingSuggestion = false;

  SearchBloc() {
    DatabaseController.instance.onPantryUpdate((myPantry, friendPantries) {
      add(_PantriesUpdated(myPantry, friendPantries));
    });
    // FIXME: Search page probably won't update if profile image updates
  }

  Pantry _myPantry;
  List<Pantry> _friendPantries;
  var _otherPantry = Pantry(
    title: "Other",
    owner: User(
      isNobody: true,
    ),
    ingredients: <PantryIngredient>[],
  );
  var _currentSearch = <PantryIngredient>[];

  @override
  SearchState get initialState => SearchLoading();

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is _PantriesUpdated) {
      _myPantry = event.myPantry;
      _friendPantries = event.friendPantries;

      if (_showingSuggestion == false) {
        yield _makeBuildingSearchState();
      }
    }

    if (event is ResultsExited) {
      yield _makeBuildingSearchState();
    }

    if (event is SearchBarEdited) {
      _barText = event.text;

      if (event.text.isEmpty) {
        _showingSuggestion = false;
        yield _makeBuildingSearchState();
        return;
      }
      _showingSuggestion = true;

      var suggestions =
          await RecipeSearch.instance.getAutoSuggestions(event.text);

      if (_barText != event.text) return;

      yield suggestions.isEmpty
          ? SuggestionsEmpty()
          : _makeSuggestingIngredientsState(suggestions);
    }

    if (event is SearchBarSubmitted) {
      if (state is SuggestingIngredient) {
        _showingSuggestion = false;
        var s = state as SuggestingIngredient;
        add(IngredientAdded(s.otherSuggestion));
      }
    }

    if (event is SearchCleared) {
      _currentSearch.clear();
      yield _makeBuildingSearchState();
    }

    if (event is IngredientAdded) {
      var ingredient = event.ingredient;

      var pantry = ingredient.fromPantry;

      bool doAdd = true;

      if (_currentSearch.contains(ingredient)) {
        doAdd = false;
      }

      if (doAdd) {
        if (pantry.owner.isNobody) {
          _otherPantry.ingredients.add(ingredient);
        }
        _currentSearch.add(ingredient);
      }
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

    _otherPantry.ingredients.clear();
    ingredients.forEach((ingredient) {
      _otherPantry.ingredients.add(ingredient);
    });

    var friendPantries = <Pantry>[];
    _friendPantries.forEach((pantry) {
      friendPantries.add(pantry);
    });

    if (_otherPantry.ingredients.isNotEmpty) {
      friendPantries.add(_otherPantry);
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

  _makeSuggestingIngredientsState(List<String> completions) {
    var name = completions[0];

    // Add suggestion for Other category above all else
    var otherSuggestion = PantryIngredient(
      name: name,
      fromPantry: _otherPantry,
    );

    // Add suggestion if my pantry contains the ingredient
    PantryIngredient myPantrySuggestion;
    bool hasIngredient = _myPantry.ingredients.contains(
      PantryIngredient(
        name: name,
        fromPantry: _myPantry,
      ),
    );
    if (hasIngredient) {
      myPantrySuggestion = PantryIngredient(
        name: name,
        fromPantry: _myPantry,
      );
    } else {
      myPantrySuggestion = null;
    }

    // Add suggestions for any friend pantries containing the ingredient
    var friendSuggestions = <PantryIngredient>[];
    try {
      var matches = _friendPantries.where((pantry) {
        return pantry.ingredients.contains(
          PantryIngredient(
            name: name,
            fromPantry: pantry,
          ),
        );
      });

      matches.forEach((pantry) {
        friendSuggestions.add(
          PantryIngredient(
            name: name,
            fromPantry: pantry,
          ),
        );
      });
    } catch (e) {}

    return SuggestingIngredient(
        otherSuggestion, myPantrySuggestion, friendSuggestions);
  }
}
