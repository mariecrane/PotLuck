import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pot_luck/controller/bloc/auth_bloc.dart';
import 'package:pot_luck/model/pantry.dart';
import 'package:pot_luck/model/user.dart';

typedef void PantryUpdateCallback(Pantry myPantry, List<Pantry> friendPantries);
typedef void FriendsUpdateCallback(List<User> friends);

class DatabaseController {
  DatabaseController._privateConstructor() {
    _authStateSubscription = AuthBloc.instance.listen(_onAuthStateChange);
  }

  void dispose() {
    _clearDocSubscriptions();
    _authStateSubscription.cancel();
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

  User _me;
  Pantry _myPantry;
  var _friendPantries = <Pantry>[];
  var _friendsList = List<User>();

  Pantry get myPantry => _myPantry;
  List<Pantry> get friendPantries => _friendPantries;
  List<User> get friendsList => _friendsList;

  var _pantryUpdateCallbacks = <PantryUpdateCallback>[];
  var _friendsUpdateCallbacks = <FriendsUpdateCallback>[];

  StreamSubscription _friendPantriesDocSubscription;
  StreamSubscription _friendRequestsDocSubscription;
  StreamSubscription _pantryDocSubscription;
  StreamSubscription _userDocSubscription;

  StreamSubscription _authStateSubscription;

  void addToMyPantry(PantryIngredient ingredient) async {
    if (_myPantry.ingredients.contains(ingredient)) return;

    var pantryDoc = Firestore.instance
        .collection("users")
        .document("${_me.id}")
        .collection("userData")
        .document("pantry");
    await Firestore.instance.runTransaction((transaction) async {
      var doc = await transaction.get(pantryDoc);
      List<String> ingredients = doc.data["ingredients"];
      if (ingredients.contains(ingredient.name)) return;
      ingredients.add(ingredient.name);
      await transaction.update(pantryDoc, <String, dynamic>{
        "ingredients": ingredients,
      });
    });
  }

  void removeFromMyPantry(PantryIngredient ingredient) async {
    if (_myPantry.ingredients.contains(ingredient) == false) return;

    var pantryDoc = Firestore.instance
        .collection("users")
        .document("${_me.id}")
        .collection("userData")
        .document("pantry");
    await Firestore.instance.runTransaction((transaction) async {
      var doc = await transaction.get(pantryDoc);
      List<String> ingredients = doc.data["ingredients"];
      if (ingredients.contains(ingredient.name) == false) return;
      ingredients.remove(ingredient.name);
      await transaction.update(pantryDoc, <String, dynamic>{
        "ingredients": ingredients,
      });
    });
  }

  void clearMyPantry() async {
    var pantryDoc = Firestore.instance
        .collection("users")
        .document("${_me.id}")
        .collection("userData")
        .document("pantry");
    await pantryDoc.updateData(<String, dynamic>{
      "ingredients": [],
    });
  }

  void sendFriendRequest(User user) async {
    // Check if user is already in the locally cached friends list, exit if so
    var alreadyFriend = true;
    try {
      _friendsList.firstWhere((friend) => friend.email == user.email);
    } catch (e) {
      alreadyFriend = false;
    }
    if (alreadyFriend) return;

    // Try to find user with given info in the database, exit if none found
    var snapshot = await Firestore.instance
        .collection("users")
        .where("email", isEqualTo: "${user.email}")
        .getDocuments();
    if (snapshot.documents.length == 0) return;

    // Send friend request to user
    String friendId = snapshot.documents[0].data["userId"];
    var me = await FirebaseAuth.instance.currentUser();
    var doc = Firestore.instance
        .collection("users")
        .document("${me.uid}")
        .collection("userData")
        .document("friendRequests");
    Firestore.instance.runTransaction((transaction) async {
      var result = await transaction.get(doc);
      List<String> requests = result.data["requestIds"];
      if (requests.contains(friendId)) return;

      requests.add(friendId);
      await transaction.update(doc, <String, dynamic>{"requestIds": requests});
    });
  }

  void removeFriend(User user) async {
    // Check if user is in the locally cached friends list, exit if not
    try {
      _friendsList.firstWhere((friend) => friend.email == user.email);
    } catch (e) {
      return;
    }

    // Remove user from friends in database
    String friendId = user.id;
    var me = await FirebaseAuth.instance.currentUser();
    var doc = Firestore.instance
        .collection("users")
        .document("${me.uid}")
        .collection("userData")
        .document("friendRequests");
    Firestore.instance.runTransaction((transaction) async {
      var result = await transaction.get(doc);
      List<String> removals = result.data["removeIds"];
      if (removals.contains(friendId)) return;

      removals.add(friendId);
      await transaction.update(doc, <String, dynamic>{"removeIds": removals});
    });
  }

  void onPantryUpdate(PantryUpdateCallback callback) {
    _pantryUpdateCallbacks.add(callback);
  }

  void onFriendsUpdate(FriendsUpdateCallback callback) {
    _friendsUpdateCallbacks.add(callback);
  }

  void _doPantryUpdateCallbacks() {
    _pantryUpdateCallbacks.forEach((callback) {
      callback(_myPantry, _friendPantries);
    });
  }

  void _doFriendsUpdateCallbacks() {
    _friendsUpdateCallbacks.forEach((callback) {
      callback(_friendsList);
    });
  }

  void _onAuthStateChange(AuthState state) async {
    _clearDocSubscriptions();

    if ((state is Authenticated) == false) {
      _me = null;
      return;
    }

    var user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      _me = User(isMe: true, id: user.uid);
      return;
    }

    _me = User(isMe: true, email: user.email, id: user.uid);
    var userDoc = Firestore.instance.collection("users").document("${_me.id}");
    var userData = userDoc.collection("userData");

    _friendPantriesDocSubscription = userData
        .document("friendPantries")
        .snapshots()
        .listen(_onFriendPantriesSnapshot);
    _friendRequestsDocSubscription = userData
        .document("friendRequests")
        .snapshots()
        .listen(_onFriendRequestsSnapshot);
    _pantryDocSubscription =
        userData.document("pantry").snapshots().listen(_onPantrySnapshot);
    _userDocSubscription = userDoc.snapshots().listen(_onUserSnapshot);
  }

  void _onPantrySnapshot(DocumentSnapshot snapshot) {
    var pantryData = snapshot.data;

    // Populate friendPantries
    var pantry = Pantry(
      owner: _me,
      title: _me.email,
      color: _colors[0],
      ingredients: List<PantryIngredient>(),
    );

    List<String> ingredientList = pantryData["ingredients"];

    ingredientList.forEach((ingredient) {
      pantry.ingredients.add(PantryIngredient(
        fromPantry: pantry,
        name: ingredient,
      ));
    });
    _doPantryUpdateCallbacks();
  }

  void _onFriendPantriesSnapshot(DocumentSnapshot snapshot) {
    List<Map<String, dynamic>> pantries = snapshot.data["pantries"];
    _friendsList.clear();
    _friendPantries.clear();

    for (int i = 0; i < pantries.length; i++) {
      var pantryData = pantries[i];

      // Populate friendsList
      var friend = User(
        id: pantryData["id"],
        email: pantryData["email"],
        // TODO: Add name to user data?
      );
      _friendsList.add(friend);

      // Populate friendPantries
      var pantry = Pantry(
        owner: friend,
        title: friend.email,
        color: _colors[i % _colors.length],
        ingredients: List<PantryIngredient>(),
      );

      List<String> ingredientList = pantryData["ingredients"];

      ingredientList.forEach((ingredient) {
        pantry.ingredients.add(PantryIngredient(
          fromPantry: pantry,
          name: ingredient,
        ));
      });

      _friendPantries.add(pantry);
    }
    _doPantryUpdateCallbacks();
    _doFriendsUpdateCallbacks();
  }

  void _onFriendRequestsSnapshot(DocumentSnapshot snapshot) {
    // TODO: Update friend requests list from snapshot
  }

  void _onUserSnapshot(DocumentSnapshot snapshot) {
    // TODO: Update user info from snapshot
  }
  void _clearDocSubscriptions() {
    _friendPantriesDocSubscription?.cancel();
    _friendRequestsDocSubscription?.cancel();
    _pantryDocSubscription?.cancel();
    _userDocSubscription?.cancel();
  }

// TODO: Remove modeled data after replacing with live data
//  Pantry _myPantry = Pantry(
//    title: 'My Pantry',
//    owner: User(name: "Me", isMe: true),
//    color: _colors[1],
//    ingredients: <PantryIngredient>[],
//  );
//  List<Pantry> _friendPantries = <Pantry>[
//    Pantry(
//      title: 'Shouayee Vue',
//      owner: User(name: "Shouayee Vue"),
//      color: _colors[2],
//      ingredients: <PantryIngredient>[],
//    ),
//    Pantry(
//      title: 'Preston Locke',
//      owner: User(name: "Preston Locke"),
//      color: _colors[3],
//      ingredients: <PantryIngredient>[],
//    ),
//    Pantry(
//      title: 'Tracy Cai',
//      owner: User(name: "Tracy Cai"),
//      color: _colors[4],
//      ingredients: <PantryIngredient>[],
//    ),
//    Pantry(
//      title: 'Marie Crane',
//      owner: User(name: "Marie Crane"),
//      color: _colors[5],
//      ingredients: <PantryIngredient>[],
//    ),
//  ];
//  void _buildPantries() {
//    _myPantry.ingredients.addAll(
//      <PantryIngredient>[
//        PantryIngredient(name: "egg", fromPantry: _myPantry),
//        PantryIngredient(name: "chicken", fromPantry: _myPantry),
//        PantryIngredient(name: "spinach", fromPantry: _myPantry),
//        PantryIngredient(name: "tofu", fromPantry: _myPantry),
//        PantryIngredient(name: "onion", fromPantry: _myPantry),
//        PantryIngredient(name: "turkey", fromPantry: _myPantry),
//      ],
//    );
//    _friendPantries[0].ingredients.add(
//          PantryIngredient(
//            name: "garlic",
//            fromPantry: _friendPantries[0],
//          ),
//        );
//    _friendPantries[0].ingredients.add(
//          PantryIngredient(
//            name: "potato",
//            fromPantry: _friendPantries[0],
//          ),
//        );
//    _friendPantries[1].ingredients.add(
//          PantryIngredient(
//            name: "apple",
//            fromPantry: _friendPantries[1],
//          ),
//        );
//    _friendPantries[2].ingredients.add(
//          PantryIngredient(
//            name: "tomato",
//            fromPantry: _friendPantries[2],
//          ),
//        );
//    _friendPantries[3].ingredients.add(
//          PantryIngredient(
//            name: "basil",
//            fromPantry: _friendPantries[3],
//          ),
//        );
//  }
}
