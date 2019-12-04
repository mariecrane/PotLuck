import 'package:bloc/bloc.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/controller/search.dart';
import 'package:pot_luck/model/pantry.dart';

abstract class PantryEvent {}

class IngredientBarEdited extends PantryEvent {
  final String text;

  IngredientBarEdited(this.text);
}

class IngredientBarSubmitted extends PantryEvent {}

class PantryIngredientAdded extends PantryEvent {
  final PantryIngredient ingredient;

  PantryIngredientAdded(this.ingredient);
}

class PantryIngredientRemoved extends PantryEvent {
  final PantryIngredient ingredient;

  PantryIngredientRemoved(this.ingredient);
}

class PantryIngredientsCleared extends PantryEvent {}

class _PantryRetrieved extends PantryEvent {
  final Pantry myPantry;

  _PantryRetrieved(this.myPantry);
}

abstract class PantryState {}

class LoadingPantry extends PantryState {}

class PantryUpdated extends PantryState {
  final Pantry pantry;

  PantryUpdated(this.pantry);
}

class SuggestingIngredients extends PantryState {
  final List<PantryIngredient> suggestions;

  SuggestingIngredients(this.suggestions);
}

class PantrySuggestionsEmpty extends PantryState {}

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
        yield PantryUpdated(pantry);
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
      yield PantryUpdated(event.myPantry);
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
