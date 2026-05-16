import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class GoogleSignInRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}

class EmailSignInRequested extends AuthEvent {
  final String email;
  final String password;
  EmailSignInRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class EmailSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  EmailSignUpRequested(this.email, this.password, this.displayName);
  @override
  List<Object?> get props => [email, password, displayName];
}

class SetupCompleted extends AuthEvent {
  final String userId;
  SetupCompleted(this.userId);
  @override
  List<Object?> get props => [userId];
}
