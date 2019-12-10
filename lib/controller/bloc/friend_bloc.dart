import 'package:bloc/bloc.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/model/user.dart';

abstract class FriendEvent {}

class FriendRemoveRequest extends FriendEvent {
  final User friend;
  FriendRemoveRequest(this.friend);
}

class FriendAddRequest extends FriendEvent {
  final String email;
  FriendAddRequest(this.email);
}

class _FriendsRetrieved extends FriendEvent {
  final List<User> friendsList;
  _FriendsRetrieved(this.friendsList);
}

class _FriendRequestsRetrieved extends FriendEvent {
  final List<User> friendRequests;
  _FriendRequestsRetrieved(this.friendRequests);
}

abstract class FriendState {}

class FriendsListUpdate extends FriendState {
  final List<User> friendsList;
  FriendsListUpdate(this.friendsList);
}

class FriendRequestsUpdate extends FriendState {
  final List<User> friendRequests;
  FriendRequestsUpdate(this.friendRequests);
}

class FriendsLoading extends FriendState {}

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  FriendBloc() {
    DatabaseController.instance.onFriendsUpdate((friends) {
      add(_FriendsRetrieved(friends));
    });
    DatabaseController.instance.onFriendRequestsUpdate((requests) {
      add(_FriendRequestsRetrieved(requests));
    });
  }

  @override
  FriendState get initialState => FriendsLoading();

  @override
  Stream<FriendState> mapEventToState(FriendEvent event) async* {
    if (event is _FriendsRetrieved) {
      yield FriendsListUpdate(event.friendsList);
    }

    if (event is _FriendRequestsRetrieved) {
      yield FriendRequestsUpdate(event.friendRequests);
    }

    if (event is FriendRemoveRequest) {
      yield FriendsLoading();

      DatabaseController.instance.removeFriend(
        event.friend,
      );
    }

    if (event is FriendAddRequest) {
      yield FriendsLoading();

      DatabaseController.instance.sendFriendRequest(
        User(email: event.email),
      );
    }
  }
}
