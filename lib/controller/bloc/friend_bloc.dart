import 'package:bloc/bloc.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/model/user.dart';

abstract class FriendsListEvent {}

class FriendRemoveRequest extends FriendsListEvent {
  final User friend;
  FriendRemoveRequest(this.friend);
}

class _FriendsRetrieved extends FriendsListEvent {
  final List<User> friendsList;
  _FriendsRetrieved(this.friendsList);
}

abstract class FriendsListState {}

class FriendsListUpdate extends FriendsListState {
  final List<User> friendsList;
  FriendsListUpdate(this.friendsList);
}

class FriendsListLoading extends FriendsListState {}

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
