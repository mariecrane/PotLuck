import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class FriendEvent {}

class FriendRemoved extends FriendEvent {
  final User friend;
  FriendRemoved(this.friend);
}

class FriendAddRequest extends FriendEvent {
  final String name;
  FriendAddRequest(this.name);
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
      try {
        // TODO: Change this to check IDs instead
        _friendsList.firstWhere((friend) => friend.name == event.name);
      } catch (e) {
        // TODO: Obviously replace this with an actual call to Firebase
        _friendsList.add(User(name: event.name));
        yield FriendsListUpdate(_friendsList);
      }
    }
  }
}

class User extends Equatable {
  final String name;
  final String id;
  final bool isNobody;
  final bool isMe;

  User({
    @required this.name,
    this.id,
    this.isNobody = false,
    this.isMe = false,
  });

  @override
  List<Object> get props => [name, isNobody, isMe];
}
