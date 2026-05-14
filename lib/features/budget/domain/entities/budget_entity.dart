import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final int month;
  final int year;

  const BudgetEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.month,
    required this.year,
  });

  String get monthKey => '$year-$month';

  @override
  List<Object?> get props => [id, userId, amount, month, year];
}
