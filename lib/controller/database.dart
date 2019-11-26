import 'package:flutter/material.dart';
import 'package:pot_luck/model/pantry.dart';
import 'package:pot_luck/model/user.dart';

typedef void PantryUpdateCallback(Pantry myPantry, List<Pantry> friendPantries);

class DatabaseController {
  DatabaseController._privateConstructor() {
    _buildPantries();
  }

  static final DatabaseController instance =
      DatabaseController._privateConstructor();
  static final List<Color> _colors = <Color>[
    Colors.blueGrey[200],
    Colors.red[700],
    Color(0xff604d53),
    Colors.deepOrange[400],
    Colors.amber[700],
    Colors.brown[300],
    Colors.purple[300],
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

  List<PantryUpdateCallback> _updateCallbacks = <PantryUpdateCallback>[];

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

  void onUpdate(PantryUpdateCallback callback) {
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
