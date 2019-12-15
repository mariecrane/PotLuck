import 'package:bloc/bloc.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/controller/search.dart';
import 'package:pot_luck/model/pantry.dart';
import 'package:pot_luck/model/recipe.dart';
import 'package:pot_luck/model/user.dart';

/// A search-related event emitted from the UI
abstract class SearchEvent {}

/// Signifies that the current ingredient search query has changed to [text]
class SearchBarEdited extends SearchEvent {
  final String text;

  SearchBarEdited(this.text);
}

/// Signifies that the user has hit submit in the ingredient search bar
class SearchBarSubmitted extends SearchEvent {}

/// Signifies that the user has hit submit on the recipe search
class Submit extends SearchEvent {}

/// Signifies that the user has added [ingredient] to their search. If
/// [fromSuggestion] is true, then the ingredient was added via auto-suggestion
class IngredientAdded extends SearchEvent {
  final PantryIngredient ingredient;
  final bool fromSuggestion;

  IngredientAdded(this.ingredient, {this.fromSuggestion = false});
}

/// Signifies that the user has removed [ingredient] from their search
class IngredientRemoved extends SearchEvent {
  final PantryIngredient ingredient;

  IngredientRemoved(this.ingredient);
}

/// Signifies that the user has tapped to exit the recipe results page
class ResultsExited extends SearchEvent {}

/// Signifies that the user has cleared their search
class SearchCleared extends SearchEvent {}

/// Signifies that the [SearchBloc] has received updated information from the
/// backend about either the user's or their friends' pantries
class _PantriesUpdated extends SearchEvent {
  final Pantry myPantry;
  final List<Pantry> friendPantries;

  _PantriesUpdated(this.myPantry, this.friendPantries);
}

/// A state emitted from [SearchBloc] to the UI
abstract class SearchState {}

/// Signifies that the UI should display the search page with the given search
/// query [allIngredients] and the given [pantries]. If [clearInput] is set to
/// true, the UI should clear any input currently displaying in the search bar.
/// This is used to clear input after successfully searching for then adding an
/// ingredient via auto-suggestion
class BuildingSearch extends SearchState {
  final List<PantryIngredient> allIngredients;
  final List<Pantry> pantries;
  final bool clearInput;

  BuildingSearch({
    this.allIngredients = const <PantryIngredient>[],
    this.pantries = const <Pantry>[],
    this.clearInput = false,
  });
}

/// Signifies that the UI should display [otherSuggestion], [myPantrySuggestion],
/// and [friendSuggestions] to the user
class SuggestingIngredient extends SearchState {
  final PantryIngredient otherSuggestion;
  final PantryIngredient myPantrySuggestion;
  final List<PantryIngredient> friendSuggestions;

  SuggestingIngredient(
      this.otherSuggestion, this.myPantrySuggestion, this.friendSuggestions);
}

/// Signifies that no auto-suggestions were found for a given search input
class SuggestionsEmpty extends SearchState {}

/// Signifies that [SearchBloc] is currently performing state-changing
/// operations, such as performing a search
class SearchLoading extends SearchState {}

/// Signifies that a search was successful and returned [results]
class SearchSuccessful extends SearchState {
  final List<SearchResult> results;

  SearchSuccessful(this.results);
}

/// Signifies that there was an error while searching for recipes. A short
/// description of the error is given by [message]
class SearchError extends SearchState {
  final String message;

  SearchError(this.message);
}

/// Accepts [SearchBloc] objects from the UI, handles those events
/// accordingly, and emits [SearchState] objects back to the UI
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  String _barText = "";
  bool _showingSuggestion = false;

  SearchBloc() {
    DatabaseController.instance.onPantryUpdate((myPantry, friendPantries) {
      add(_PantriesUpdated(myPantry, friendPantries));
    });
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
  bool _clearInput = false;

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

      _clearInput = event.fromSuggestion;

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

    var clear = _clearInput;
    _clearInput = false;

    return BuildingSearch(
      allIngredients: _currentSearch,
      pantries: allPantries,
      clearInput: clear,
    );
  }

  /// Removes [PantryIngredient] objects from the current search if they no
  /// longer exist in any pantry
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
