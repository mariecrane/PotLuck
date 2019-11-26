import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String name;
  final String email;
  final String id;
  final bool isNobody;
  final bool isMe;

  User({
    this.name,
    this.email,
    this.id,
    this.isNobody = false,
    this.isMe = false,
  });

  @override
  List<Object> get props => [name, isNobody, isMe];
}
