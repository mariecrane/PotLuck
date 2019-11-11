import 'package:bloc/bloc.dart';

abstract class FriendEvent {}

abstract class FriendState {}

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  @override
  // TODO: implement initialState
  FriendState get initialState => null;

  @override
  Stream<FriendState> mapEventToState(FriendEvent event) {
    // TODO: implement mapEventToState
    return null;
  }
}
