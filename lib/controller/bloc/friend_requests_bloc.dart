import 'package:bloc/bloc.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/model/user.dart';

/// Authors: Preston Locke
/// This is the business logic component for events related to the user's
/// incoming and outgoing friend requests. It responds to actions by the user
/// and supplies state information back to the UI

/// An event emitted from the UI that is related to the user's friend requests,
/// both incoming and outgoing
abstract class FriendRequestsEvent {}

/// Signifies that the current user has requested to add a [User] with the given
/// [email] to their friends. This may be because of a direct search for that
/// person, or because the user accepted a preexisting friend request from them
class FriendAddRequest extends FriendRequestsEvent {
  final String email;
  FriendAddRequest(this.email);
}

/// Signifies that the [FriendRequestsBloc] has received updated information
/// from the backend. This is triggered whenever a [User] is added or removed from
/// the list of friend requests
class _FriendRequestsRetrieved extends FriendRequestsEvent {
  final List<User> friendRequests;
  _FriendRequestsRetrieved(this.friendRequests);
}

/// A state emitted from [FriendsRequestsBloc] to the UI
abstract class FriendRequestsState {}

/// Signifies that the list of friend requests has changed in some way
class FriendRequestsUpdate extends FriendRequestsState {
  final List<User> friendRequests;
  FriendRequestsUpdate(this.friendRequests);
}

/// Signifies that the [FriendRequestsBloc] is currently performing some kind of
/// state-changing operation
class FriendRequestsLoading extends FriendRequestsState {}

/// Accepts [FriendRequestsEvent] objects from the UI, handles those events
/// accordingly, and emits [FriendRequestsState] objects back to the UI
class FriendRequestsBloc
    extends Bloc<FriendRequestsEvent, FriendRequestsState> {
  FriendRequestsBloc() {
    DatabaseController.instance.onFriendRequestsUpdate((requests) {
      add(_FriendRequestsRetrieved(requests));
    });
  }

  @override
  FriendRequestsState get initialState => FriendRequestsLoading();

  @override
  Stream<FriendRequestsState> mapEventToState(
      FriendRequestsEvent event) async* {
    if (event is _FriendRequestsRetrieved) {
      yield FriendRequestsUpdate(event.friendRequests);
    }

    if (event is FriendAddRequest) {
      DatabaseController.instance.sendFriendRequest(
        User(email: event.email),
      );
    }
  }
}
