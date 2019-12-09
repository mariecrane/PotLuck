import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pot_luck/model/pantry.dart';
import 'package:pot_luck/model/user.dart';

typedef void PantryUpdateCallback(Pantry myPantry, List<Pantry> friendPantries);
typedef void FriendsUpdateCallback(List<User> friends);
typedef void AuthUpdateCallback(User currentUser);

class DatabaseController {
  DatabaseController._privateConstructor() {
    _authStateSubscription =
        FirebaseAuth.instance.onAuthStateChanged.listen(_onAuthStateChange);
  }

  void dispose() {
    _clearDocSubscriptions();
    _authStateSubscription.cancel();
  }

  static final DatabaseController instance =
      DatabaseController._privateConstructor();

  static final List<Color> _colors = <Color>[
    Color(0xffe28413),
    Color(0xff604d53),
    Color(0xff604d53),
    Color(0xff604d53),
    Color(0xff604d53),
    Color(0xff604d53),
    Color(0xff604d53),
  ];

  User _me;
  Pantry _myPantry;
  var _friendPantries = <Pantry>[];
  var _friendsList = <User>[];

  Pantry get myPantry => _myPantry;
  List<Pantry> get friendPantries => _friendPantries;
  List<User> get friendsList => _friendsList;

  var _pantryUpdateCallbacks = <PantryUpdateCallback>[];
  var _friendsUpdateCallbacks = <FriendsUpdateCallback>[];
  var _authUpdateCallbacks = <AuthUpdateCallback>[];

  StreamSubscription _friendPantriesDocSubscription;
  StreamSubscription _friendRequestsDocSubscription;
  StreamSubscription _pantryDocSubscription;
  StreamSubscription _userDocSubscription;

  StreamSubscription _authStateSubscription;

  void signInAnonymously() async {
    // Don't do anything if already signed in somewhere. Need to sign out first
    if (_me != null) return;

    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      _doAuthUpdateCallbacks();
    }
  }

  void createAccount(String email, String password) async {
    // Don't do anything if already signed in somewhere. Need to sign out first
    if (_me != null) return;

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _doAuthUpdateCallbacks();
    }
  }

  void signIn(String email, String password) async {
    // Don't do anything if already signed in somewhere. Need to sign out first
    if (_me != null) return;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _doAuthUpdateCallbacks();
    }
  }

  void signOut() async {
    // Don't do anything if not already signed in. Need to sign in first
    if (_me == null) return;

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      _doAuthUpdateCallbacks();
    }
  }

  void deleteAccount() async {
    // Don't do anything if not already signed in. Need to sign in first
    if (_me == null) return;

    try {
      var user = await FirebaseAuth.instance.currentUser();
      await user.delete();
    } catch (e) {
      _doAuthUpdateCallbacks();
    }
  }

  void updateProfileImage(File imageFile) async {
    var ext = imageFile.path.substring(imageFile.path.lastIndexOf("."));
    var path = "users/images/${_me.id}$ext";
    var imageRef = FirebaseStorage.instance.ref().child(path);
    var previous = _me.imageURI;

    // Upload image file to cloud storage
    var task = imageRef.putFile(imageFile);
    var snapshot = await task.onComplete;

    // Delete FirebaseImage cache to force reload of image
    var temp = await getTemporaryDirectory();
    var files = temp.listSync();
    files.forEach((file) async {
      if (file.path.contains("firebase_image")) {
        await file.delete(recursive: true);
      }
    });

    // Change imageURI field in user doc
    var bucket = await snapshot.ref.getBucket();
    var userRef = Firestore.instance.collection("users").document(_me.id);
    var uri = "gs://$bucket/$path";
    await userRef.updateData(<String, dynamic>{
      "imageURI": uri,
    });

    // If last image is not the default and has different URI, delete it
    if (previous.contains("profile.png") == false && previous != uri) {
      var ref = await FirebaseStorage.instance.getReferenceFromUrl(previous);
      await ref.delete();
    }

    _me = User(
      id: _me.id,
      email: _me.email,
      imageURI: uri,
      isMe: true,
    );

    _myPantry = Pantry(
      owner: _me,
      title: _me.email,
      color: _colors[0],
      ingredients: _myPantry.ingredients,
    );

    _doAuthUpdateCallbacks();
    _doPantryUpdateCallbacks();
  }

  void addToMyPantry(PantryIngredient ingredient) async {
    if (_myPantry.ingredients.contains(ingredient)) return;

    var pantryDoc = Firestore.instance
        .collection("users")
        .document("${_me.id}")
        .collection("userData")
        .document("pantry");
    await Firestore.instance.runTransaction((transaction) async {
      var doc = await transaction.get(pantryDoc);
      List<String> ingredients =
          doc.data["ingredients"].map<String>((i) => i as String).toList();
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
      List<String> ingredients =
          doc.data["ingredients"].map<String>((i) => i as String).toList();
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
      List<String> requests =
          result.data["requestToIds"].map<String>((r) => r as String).toList();
      if (requests.contains(friendId)) return;

      requests.add(friendId);
      await transaction
          .update(doc, <String, dynamic>{"requestToIds": requests});
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
      List<String> removals =
          result.data["removeIds"].map<String>((r) => r as String).toList();
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

  void onAuthUpdate(AuthUpdateCallback callback) {
    _authUpdateCallbacks.add(callback);
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

  void _doAuthUpdateCallbacks() {
    _authUpdateCallbacks.forEach((callback) {
      callback(_me);
    });
  }

  void _onAuthStateChange(FirebaseUser user) async {
    _clearDocSubscriptions();

    // TODO: Make sure Firebase Auth gives null when signed out
    if (user == null) {
      _me = null;
      _doAuthUpdateCallbacks();
      return;
    }

    if (user.isAnonymous) {
      _me = User(isMe: true, id: user.uid);
      _doAuthUpdateCallbacks();
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

    _doAuthUpdateCallbacks();
  }

  void _onPantrySnapshot(DocumentSnapshot snapshot) {
    if (snapshot == null) return;

    var pantryData = snapshot.data;

    _myPantry = Pantry(
      owner: _me,
      title: _me.email,
      color: Color(0xffe28413),
      ingredients: List<PantryIngredient>(),
    );

    List<dynamic> ingredientList = pantryData["ingredients"];

    ingredientList.forEach((ingredient) {
      _myPantry.ingredients.add(PantryIngredient(
        fromPantry: _myPantry,
        name: ingredient,
      ));
    });

    _doPantryUpdateCallbacks();
  }

  void _onFriendPantriesSnapshot(DocumentSnapshot snapshot) {
    if (snapshot == null) return;

    List<dynamic> pantries = snapshot.data["friendPantries"];
    _friendsList.clear();
    _friendPantries.clear();

    for (int i = 0; i < pantries.length; i++) {
      var pantryData = pantries[i];

      // Populate friendsList
      var friend = User(
        id: pantryData["id"],
        email: pantryData["email"],
        imageURI: pantryData["imageURI"],
        // TODO: Add name to user data?
      );
      _friendsList.add(friend);

      // Populate friendPantries
      var pantry = Pantry(
        owner: friend,
        title: friend.email,
        color: Color(0xff604d53),
//        color: _colors[(i % (_colors.length - 1)) + 1],
        ingredients: List<PantryIngredient>(),
      );

      List<String> ingredientList =
          pantryData["pantry"].map<String>((i) => i as String).toList();

      ingredientList.forEach((ingredient) {
        pantry.ingredients.add(PantryIngredient(
          fromPantry: pantry,
          name: ingredient,
        ));
      });

      _friendPantries.add(pantry);
    }

    if (_myPantry != null) {
      _doPantryUpdateCallbacks();
    }
    _doFriendsUpdateCallbacks();
  }

  void _onFriendRequestsSnapshot(DocumentSnapshot snapshot) {
    // TODO: Update friend requests list from snapshot
  }

  void _onUserSnapshot(DocumentSnapshot snapshot) {
    if (snapshot == null) return;

    var data = snapshot.data;

    _me = User(
      id: data["userId"],
      email: data["email"],
      imageURI: data["imageURI"],
      isMe: true,
    );

    _myPantry = Pantry(
      owner: _me,
      title: _me.email,
      color: _colors[0],
      ingredients: _myPantry.ingredients,
    );

    _doAuthUpdateCallbacks();
    _doPantryUpdateCallbacks();
  }

  void _clearDocSubscriptions() {
    _friendPantriesDocSubscription?.cancel();
    _friendRequestsDocSubscription?.cancel();
    _pantryDocSubscription?.cancel();
    _userDocSubscription?.cancel();
  }
}
