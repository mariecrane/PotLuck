import 'package:bloc/bloc.dart';
import 'package:pot_luck/controller/database.dart';
import 'package:pot_luck/model/user.dart';

abstract class ProfileEvent {}

// TODO: Implement profile picture selection and upload
class PictureSelected extends ProfileEvent {}

class _ProfileUpdated extends ProfileEvent {
  final User profile;
  _ProfileUpdated(this.profile);
}

abstract class ProfileState {}

class ProfileLoading extends ProfileState {}

class NotSignedIn extends ProfileState {}

class DisplayingProfile extends ProfileState {
  final User profile;
  DisplayingProfile(this.profile);
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() {
    DatabaseController.instance.onAuthUpdate((profile) async {
      add(_ProfileUpdated(profile));
    });
  }

  @override
  ProfileState get initialState => ProfileLoading();

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is _ProfileUpdated) {
      if (event.profile == null || event.profile.isNobody) {
        yield NotSignedIn();
        return;
      }

      yield DisplayingProfile(event.profile);
    }
  }
}
