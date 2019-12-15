import 'package:bloc/bloc.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/model/user.dart';

/// An event emitted from the UI that is related to the user's friends list
abstract class FriendsListEvent {}

/// Signifies that the user has requested to remove [friend] from their friends
/// list
class FriendRemoveRequest extends FriendsListEvent {
  final User friend;
  FriendRemoveRequest(this.friend);
}

/// Signifies that the [FriendsListBloc] has received updated information from
/// the backend. This is triggered whenever a [User] is added or removed from
/// the friends list, or when a friend changes their profile information
class _FriendsRetrieved extends FriendsListEvent {
  final List<User> friendsList;
  _FriendsRetrieved(this.friendsList);
}

/// A state emitted from [FriendsListBloc] to the UI
abstract class FriendsListState {}

/// Signifies that the current user's friends list has updated in some way
class FriendsListUpdate extends FriendsListState {
  final List<User> friendsList;
  FriendsListUpdate(this.friendsList);
}

/// Signifies that the [FriendsListBloc] is currently performing some kind of
/// state-changing operation, like attempting to remove a [User] from the
/// friends list
class FriendsListLoading extends FriendsListState {}

/// Accepts [FriendsListEvent] objects from the UI, handles those events
/// accordingly, and emits [FriendsListState] objects back to the UI
class FriendsListBloc extends Bloc<FriendsListEvent, FriendsListState> {
  FriendsListBloc() {
    DatabaseController.instance.onFriendsUpdate((friends) {
      add(_FriendsRetrieved(friends));
    });
  }

  @override
  FriendsListState get initialState => FriendsListLoading();

  @override
  Stream<FriendsListState> mapEventToState(FriendsListEvent event) async* {
    if (event is _FriendsRetrieved) {
      yield FriendsListUpdate(event.friendsList);
    }

    if (event is FriendRemoveRequest) {
      yield FriendsListLoading();

      DatabaseController.instance.removeFriend(
        event.friend,
      );
    }
  }
}
