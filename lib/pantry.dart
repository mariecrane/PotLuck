//TODO: this is hard-coded and very inefficient; ideally it changes depends on the friend but I cannot do anything about that now
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pot_luck/friend.dart';

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

class PantryUpdateRequested extends PantryEvent {}

abstract class PantryState {}

class LoadingPantries extends PantryState {}

class PantryUpdated extends PantryState {
  final Pantry pantry;
  PantryUpdated(this.pantry);
}

class PantryBloc extends Bloc<PantryEvent, PantryState> {
  PantryBloc() {
    add(PantryUpdateRequested());
  }

  @override
  PantryState get initialState => LoadingPantries();

  @override
  Stream<PantryState> mapEventToState(PantryEvent event) async* {
    if (event is PantryIngredientAdded) {
      var pantry = await PantryFetcher.instance.addToMyPantry(event.ingredient);
      yield PantryUpdated(pantry);
    }

    if (event is PantryIngredientRemoved) {
      var pantry =
          await PantryFetcher.instance.removeFromMyPantry(event.ingredient);
      yield PantryUpdated(pantry);
    }

    if (event is PantryIngredientsCleared) {
      var pantry = await PantryFetcher.instance.clearMyPantry();
      yield PantryUpdated(pantry);
    }

    if (event is PantryUpdateRequested) {
      // TODO: Make an actual request for current pantry data
      var pantry = await PantryFetcher.instance.getMyPantry();
      yield PantryUpdated(pantry);
    }
  }
}

/// Simple data model for a single pantry with a title and a specific color
class Pantry extends Equatable {
  final User owner;
  final String title;
  final Color color;
  final List<PantryIngredient> ingredients;

  Pantry({this.owner, this.title, this.color, @required this.ingredients});

  @override
  List<Object> get props => [owner];
}

/// Simple data model for a single ingredient stored in a pantry
class PantryIngredient extends Equatable {
  final Pantry fromPantry;
  final int id;
  final String name;
  final double amount;
  final String unit;

  PantryIngredient({
    this.fromPantry,
    this.id,
    this.name,
    this.amount,
    this.unit,
  });

  @override
  List<Object> get props => [name, fromPantry];
}

typedef void UpdateCallback(Pantry myPantry, List<Pantry> friendPantries);

class PantryFetcher {
  PantryFetcher._privateConstructor() {
    _buildPantries();
  }

  static final PantryFetcher instance = PantryFetcher._privateConstructor();
  static final List<Color> _colors = <Color>[
    Colors.blueGrey[150],
    Colors.brown[300],
    Colors.deepOrange[300],
    Colors.cyan,
    Colors.purple[300],
    Colors.green[400],
    Colors.pink[200],
    Colors.teal[200]
  ];

  Pantry _myPantry = Pantry(
    title: 'My Pantry',
    owner: User(name: "Me", isMe: true),
    color: _colors[1],
    ingredients: <PantryIngredient>[],
  );

  List<Pantry> _friendPantries = <Pantry>[
    Pantry(
      title: 'Shouayee Vue',
      owner: User(name: "Shouayee Vue"),
      color: _colors[2],
      ingredients: <PantryIngredient>[],
    ),
    Pantry(
      title: 'Preston Locke',
      owner: User(name: "Preston Locke"),
      color: _colors[3],
      ingredients: <PantryIngredient>[],
    ),
    Pantry(
      title: 'Tracy Cai',
      owner: User(name: "Tracy Cai"),
      color: _colors[4],
      ingredients: <PantryIngredient>[],
    ),
    Pantry(
      title: 'Marie Crane',
      owner: User(name: "Marie Crane"),
      color: _colors[5],
      ingredients: <PantryIngredient>[],
    ),
  ];

  List<UpdateCallback> _updateCallbacks = <UpdateCallback>[];

  Future<Pantry> getMyPantry() async {
    // TODO: Actually request pantry from Firebase
    return _myPantry;
  }

  Future<Pantry> addToMyPantry(PantryIngredient ingredient) async {
    // TODO: Actually request pantry from Firebase
    if (_myPantry.ingredients.contains(ingredient) == false) {
      _myPantry.ingredients.add(ingredient);
    }
    doUpdateCallbacks();
    return _myPantry;
  }

  Future<Pantry> removeFromMyPantry(PantryIngredient ingredient) async {
    // TODO: Actually request pantry from Firebase
    if (_myPantry.ingredients.contains(ingredient)) {
      _myPantry.ingredients.remove(ingredient);
    }
    doUpdateCallbacks();
    return _myPantry;
  }

  Future<Pantry> clearMyPantry() async {
    _myPantry.ingredients.clear();
    doUpdateCallbacks();
    return _myPantry;
  }

  Future<List<Pantry>> getFriendPantries() async {
    // TODO: Actually request pantries from Firebase
    return _friendPantries;
  }

  void onUpdate(UpdateCallback callback) {
    _updateCallbacks.add(callback);
  }

  void doUpdateCallbacks() async {
    _updateCallbacks.forEach((callback) {
      callback(_myPantry, _friendPantries);
    });
  }

  // TODO: Get rid of this when replacing with live data
  void _buildPantries() {
    _myPantry.ingredients.addAll(
      <PantryIngredient>[
        PantryIngredient(name: "egg", fromPantry: _myPantry),
        PantryIngredient(name: "chicken", fromPantry: _myPantry),
        PantryIngredient(name: "spinach", fromPantry: _myPantry),
        PantryIngredient(name: "tofu", fromPantry: _myPantry),
        PantryIngredient(name: "onion", fromPantry: _myPantry),
        PantryIngredient(name: "turkey", fromPantry: _myPantry),
      ],
    );
    _friendPantries[0].ingredients.add(
          PantryIngredient(
            name: "garlic",
            fromPantry: _friendPantries[0],
          ),
        );
    _friendPantries[0].ingredients.add(
          PantryIngredient(
            name: "potato",
            fromPantry: _friendPantries[0],
          ),
        );
    _friendPantries[1].ingredients.add(
          PantryIngredient(
            name: "apple",
            fromPantry: _friendPantries[1],
          ),
        );
    _friendPantries[2].ingredients.add(
          PantryIngredient(
            name: "tomato",
            fromPantry: _friendPantries[2],
          ),
        );
    _friendPantries[3].ingredients.add(
          PantryIngredient(
            name: "basil",
            fromPantry: _friendPantries[3],
          ),
        );
  }
}
