import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pot_luck/model/user.dart';

abstract class FriendEvent {}

class FriendRemoved extends FriendEvent {
  final User friend;
  FriendRemoved(this.friend);
}

class FriendAddRequest extends FriendEvent {
  final String email;
  FriendAddRequest(this.email);
}

abstract class FriendState {}

class FriendsListUpdate extends FriendState {
  final List<User> friendsList;
  FriendsListUpdate(this.friendsList);
}

class FriendsListEmpty extends FriendState {}

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  List<User> _friendsList = <User>[
    User(name: "Marie Crane"),
    User(name: "Preston Locke"),
    User(name: "Shouayee Vue"),
    User(name: "Tracy Cai"),
  ];

  @override
  // TODO: implement initialState
  FriendState get initialState => FriendsListUpdate(_friendsList);

  @override
  Stream<FriendState> mapEventToState(FriendEvent event) async* {
    if (event is FriendRemoved) {
      _friendsList.removeWhere((friend) => friend == event.friend);
      yield _friendsList.isEmpty
          ? FriendsListEmpty()
          : FriendsListUpdate(_friendsList);
    }

    if (event is FriendAddRequest) {
      var alreadyFriend = true;
      try {
        _friendsList.firstWhere((friend) => friend.email == event.email);
      } catch (e) {
        alreadyFriend = false;
      }
      if (alreadyFriend) return;
      // TODO: Obviously replace this with an actual call to Firebase
//      _friendsList.add(User(email: event.email));

      var snapshot = await Firestore.instance
          .collection("users")
          .where("email", isEqualTo: "${event.email}")
          .getDocuments();
      if (snapshot.documents.length == 0) {
        yield FriendsListUpdate(_friendsList);
        return;
      }
      String friendId = snapshot.documents[0].data["userId"];

      var user = await FirebaseAuth.instance.currentUser();
      var doc = Firestore.instance
          .collection("users")
          .document("${user.uid}")
          .collection("userData")
          .document("friendRequests");

      Firestore.instance.runTransaction((transaction) async {
        var result = await transaction.get(doc);
        List<String> requests = result.data["requestIds"];
        if (requests.contains(friendId)) return;

        requests.add(friendId);
        await transaction
            .update(doc, <String, dynamic>{"requestIds": requests});
      });
      yield FriendsListUpdate(_friendsList);
    }
  }
}
