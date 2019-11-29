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

abstract class FriendState {}

class FriendsListUpdate extends FriendState {
  final List<User> friendsList;
  FriendsListUpdate(this.friendsList);
}

class FriendsListEmpty extends FriendState {}

class FriendsLoading extends FriendState {}

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  FriendBloc._privateConstructor() {
    DatabaseController.instance.onFriendsUpdate((friends) {
      add(_FriendsRetrieved(friends));
    });
  }
  // ignore: close_sinks
  static final instance = FriendBloc._privateConstructor();

  @override
  FriendState get initialState => FriendsLoading();

  @override
  Stream<FriendState> mapEventToState(FriendEvent event) async* {
    if (event is _FriendsRetrieved) {
      yield event.friendsList.isEmpty
          ? FriendsListEmpty()
          : FriendsListUpdate(event.friendsList);
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
