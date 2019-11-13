import 'package:bloc/bloc.dart';

abstract class FriendEvent {}

class FriendRemoved extends FriendEvent {
  final Friend friend;

  FriendRemoved(this.friend);
}

abstract class FriendState {}

class FriendsListUpdate extends FriendState {
  final List<Friend> friendsList;

  FriendsListUpdate(this.friendsList);
}

class FriendsListEmpty extends FriendState {}

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  List<Friend> _friendsList = <Friend>[
    Friend("Marie Crane", "alskdjf98123fe98hj"),
    Friend("Preston Locke", "3skdhjfaljf9812e98"),
    Friend("Shouayee Vue", "98djfalsk8hjfe9123"),
    Friend("Tracy Cai", "lskf812djah9f3je98"),
  ];

  @override
  // TODO: implement initialState
  FriendState get initialState => FriendsListUpdate(_friendsList);

  @override
  Stream<FriendState> mapEventToState(FriendEvent event) async* {
    // TODO: implement mapEventToState
    if (event is FriendRemoved) {
      _friendsList.removeWhere((friend) => friend == event.friend);
      yield _friendsList.isEmpty
          ? FriendsListEmpty()
          : FriendsListUpdate(_friendsList);
    }
  }
}

class Friend {
  final String name;
  final String id;

  Friend(this.name, this.id);
}
