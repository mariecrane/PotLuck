import 'package:bloc/bloc.dart';
import 'package:pot_luck/controller/database.dart';
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

class _FriendsRetrieved extends FriendEvent {
  final List<User> friendsList;

  _FriendsRetrieved(this.friendsList);
}

abstract class FriendState {}

class FriendsListUpdate extends FriendState {
  final List<User> friendsList;
  FriendsListUpdate(this.friendsList);
}

class FriendsListEmpty extends FriendState {}

class FriendsLoading extends FriendState {}

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  FriendBloc() {
    DatabaseController.instance.getFriendsList().then((friends) {
      add(_FriendsRetrieved(friends));
    });
  }

  @override
  // TODO: implement initialState
  FriendState get initialState => FriendsLoading();

  @override
  Stream<FriendState> mapEventToState(FriendEvent event) async* {
    if (event is FriendRemoved) {
      yield FriendsLoading();

      var friendsList = await DatabaseController.instance.removeFriend(
        event.friend,
      );
      yield friendsList.isEmpty
          ? FriendsListEmpty()
          : FriendsListUpdate(friendsList);
    }

    if (event is FriendAddRequest) {
      yield FriendsLoading();

      var friendsList = await DatabaseController.instance.sendFriendRequest(
        User(email: event.email),
      );
      yield FriendsListUpdate(friendsList);
    }
  }
}
