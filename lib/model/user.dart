import 'package:equatable/equatable.dart';

/// Authors: Preston Locke
/// These are the data models related to user information saved in the database

/// Models a single user's information. Might be the current logged in user, or
/// have the [isNobody] attribute set to indicate the absence of a real user.
class User extends Equatable {
  final String name;
  final String email;
  final String id;
  final String imageURI;
  final bool isNobody;
  final bool isMe;

  User({
    this.name,
    this.email,
    this.id,
    this.imageURI = "gs://potluck-d1796.appspot.com/users/images/profile.png",
    this.isNobody = false,
    this.isMe = false,
  });

  @override
  List<Object> get props => [id, isNobody, isMe];
}
