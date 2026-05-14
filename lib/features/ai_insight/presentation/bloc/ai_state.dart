import 'package:equatable/equatable.dart';

abstract class AiState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AiInitial extends AiState {}

class AiLoading extends AiState {}

class AiLoaded extends AiState {
  final String insight;
  AiLoaded(this.insight);

  @override
  List<Object?> get props => [insight];
}

class AiError extends AiState {
  final String message;
  AiError(this.message);

  @override
  List<Object?> get props => [message];
}
