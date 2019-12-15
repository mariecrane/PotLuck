import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pot_luck/model/user.dart';

/// Models a pantry belonging to [owner] with a [title] and a specific [color]
class Pantry extends Equatable {
  final User owner;
  final String title;
  final Color color;
  final List<PantryIngredient> ingredients;

  Pantry({this.owner, this.title, this.color, @required this.ingredients});

  @override
  List<Object> get props => [owner];
}

/// Models a single ingredient stored in [fromPantry]
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
