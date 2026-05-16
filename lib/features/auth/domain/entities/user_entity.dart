import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String currency;
  final String language;
  final String theme;
  final bool isSetupComplete;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.currency = 'USD',
    this.language = 'en',
    this.theme = 'system',
    this.isSetupComplete = false,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    currency,
    language,
    theme,
    isSetupComplete,
  ];
}
