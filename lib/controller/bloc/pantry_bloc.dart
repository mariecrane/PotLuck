import 'package:bloc/bloc.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/controller/search.dart';
import 'package:pot_luck/model/pantry.dart';

/// An event emitted from the UI that is related to the user's pantry
abstract class PantryEvent {}

/// Signifies that the current ingredient search query has changed to [text]
class IngredientBarEdited extends PantryEvent {
  final String text;

  IngredientBarEdited(this.text);
}

/// Signifies that the user has hit submit in the ingredient search bar
class IngredientBarSubmitted extends PantryEvent {}

/// Signifies that the user has requested to add [ingredient] to their pantry
class PantryIngredientAdded extends PantryEvent {
  final PantryIngredient ingredient;

  PantryIngredientAdded(this.ingredient);
}

/// Signifies that the user has requested to remove [ingredient] from their pantry
class PantryIngredientRemoved extends PantryEvent {
  final PantryIngredient ingredient;

  PantryIngredientRemoved(this.ingredient);
}

/// Signifies that the user has requested to clear their pantry of ingredients
class PantryIngredientsCleared extends PantryEvent {}

/// Signifies that the [PantryBloc] has received updated information from the
/// backend about the user's pantry. This is triggered whenever any
/// [PantryIngredient] is added or removed
class _PantryRetrieved extends PantryEvent {
  final Pantry myPantry;

  _PantryRetrieved(this.myPantry);
}

/// A state emitted from [PantryBloc] to the UI
abstract class PantryState {}

/// Signifies that the [PantryBloc] is currently performing some kind of
/// state-changing operation, such as adding or removing ingredients from the
/// user's pantry, or clearing it completely
class LoadingPantry extends PantryState {}

/// Signifies that the contents of the current user's [Pantry] has changed in
/// some way. If [clearInput] is set to true, the UI should clear any input
/// currently displaying in the search bar. This is used to clear input after
/// successfully searching for then adding an ingredient via auto-suggestion
class PantryUpdated extends PantryState {
  final Pantry pantry;
  final bool clearInput;

  PantryUpdated(this.pantry, {this.clearInput = false});
}

/// Signifies that the UI should display [suggestions] to the user
class SuggestingIngredients extends PantryState {
  final List<PantryIngredient> suggestions;

  SuggestingIngredients(this.suggestions);
}

/// Signifies that no auto-suggestions were found for a given search input
class PantrySuggestionsEmpty extends PantryState {}

/// Accepts [PantryEvent] objects from the UI, handles those events
/// accordingly, and emits [PantryState] objects back to the UI
class PantryBloc extends Bloc<PantryEvent, PantryState> {
  String _barText = "";

  PantryBloc() {
    DatabaseController.instance.onPantryUpdate((myPantry, friendPantries) {
      add(_PantryRetrieved(myPantry));
    });
  }

  @override
  PantryState get initialState => LoadingPantry();

  @override
  Stream<PantryState> mapEventToState(PantryEvent event) async* {
    if (event is IngredientBarSubmitted) {
      if (state is SuggestingIngredients) {
        var s = state as SuggestingIngredients;
        add(PantryIngredientAdded(s.suggestions[0]));
      }
    }

    if (event is IngredientBarEdited) {
      _barText = event.text;

      if (_barText.isEmpty) {
        yield PantryUpdated(DatabaseController.instance.myPantry);
        return;
      }

      var completions =
          await RecipeSearch.instance.getAutoSuggestions(event.text);

      if (_barText != event.text) return;

      yield completions.isEmpty
          ? PantrySuggestionsEmpty()
          : _makeSuggestingIngredientsState(completions);
    }

    if (event is PantryIngredientAdded) {
      var pantry = DatabaseController.instance.myPantry;
      if (pantry.ingredients.contains(event.ingredient)) {
        yield PantryUpdated(pantry, clearInput: true);
        return;
      }

      yield LoadingPantry();
      DatabaseController.instance.addToMyPantry(event.ingredient);
    }

    if (event is PantryIngredientRemoved) {
      yield LoadingPantry();
      DatabaseController.instance.removeFromMyPantry(event.ingredient);
    }

    if (event is PantryIngredientsCleared) {
      yield LoadingPantry();
      DatabaseController.instance.clearMyPantry();
    }

    if (event is _PantryRetrieved) {
      yield PantryUpdated(event.myPantry, clearInput: true);
    }
  }

  _makeSuggestingIngredientsState(List<String> completions) {
    var suggestions = completions.map<PantryIngredient>((name) {
      return PantryIngredient(
        name: name,
        fromPantry: DatabaseController.instance.myPantry,
      );
    }).toList();
    return SuggestingIngredients(suggestions);
  }
}
