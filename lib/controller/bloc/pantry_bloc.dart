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

class PantryBloc extends Bloc<PantryEvent, PantryState> {
  PantryBloc._privateConstructor() {
    DatabaseController.instance.onPantryUpdate((myPantry, friendPantries) {
      add(_PantryRetrieved(myPantry));
    });
  }
  // ignore: close_sinks
  static final instance = PantryBloc._privateConstructor();

  @override
  PantryState get initialState => LoadingPantry();

  @override
  Stream<PantryState> mapEventToState(PantryEvent event) async* {
    if (event is PantryIngredientAdded) {
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
}
