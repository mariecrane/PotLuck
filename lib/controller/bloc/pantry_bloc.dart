import 'package:bloc/bloc.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/model/pantry.dart';

abstract class PantryEvent {}

class PantryIngredientAdded extends PantryEvent {
  final PantryIngredient ingredient;
  PantryIngredientAdded(this.ingredient);
}

class PantryIngredientRemoved extends PantryEvent {
  final PantryIngredient ingredient;
  PantryIngredientRemoved(this.ingredient);
}

class PantryIngredientsCleared extends PantryEvent {}

class _PantryUpdateRequested extends PantryEvent {}

abstract class PantryState {}

class LoadingPantries extends PantryState {}

class PantryUpdated extends PantryState {
  final Pantry pantry;
  PantryUpdated(this.pantry);
}

class PantryBloc extends Bloc<PantryEvent, PantryState> {
  PantryBloc() {
    add(_PantryUpdateRequested());
  }

  @override
  PantryState get initialState => LoadingPantries();

  @override
  Stream<PantryState> mapEventToState(PantryEvent event) async* {
    if (event is PantryIngredientAdded) {
      var pantry =
          await DatabaseController.instance.addToMyPantry(event.ingredient);
      yield PantryUpdated(pantry);
    }

    if (event is PantryIngredientRemoved) {
      var pantry = await DatabaseController.instance
          .removeFromMyPantry(event.ingredient);
      yield PantryUpdated(pantry);
    }

    if (event is PantryIngredientsCleared) {
      var pantry = await DatabaseController.instance.clearMyPantry();
      yield PantryUpdated(pantry);
    }

    if (event is _PantryUpdateRequested) {
      // TODO: Make an actual request for current pantry data
      var pantry = await DatabaseController.instance.getMyPantry();
      yield PantryUpdated(pantry);
    }
  }
}
