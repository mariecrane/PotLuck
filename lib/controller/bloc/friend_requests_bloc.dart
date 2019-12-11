import 'package:bloc/bloc.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/model/user.dart';

abstract class FriendRequestsEvent {}

class FriendAddRequest extends FriendRequestsEvent {
  final String email;
  FriendAddRequest(this.email);
}

class _FriendRequestsRetrieved extends FriendRequestsEvent {
  final List<User> friendRequests;
  _FriendRequestsRetrieved(this.friendRequests);
}

abstract class FriendRequestsState {}

class FriendRequestsUpdate extends FriendRequestsState {
  final List<User> friendRequests;
  FriendRequestsUpdate(this.friendRequests);
}

class FriendRequestsLoading extends FriendRequestsState {}

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
