import 'package:flutter/material.dart';

/// Returns an appropriate [IconData] for a given expense category name.
/// If the category is unrecognized, a generic icon is returned.
IconData getIconForCategory(String name) {
  switch (name) {
    case 'Food':
      return Icons.fastfood;
    case 'Transport':
      return Icons.directions_car;
    case 'Shopping':
      return Icons.shopping_bag;
    case 'Bills':
      return Icons.receipt_long;
    case 'Health':
      return Icons.health_and_safety;
    case 'Entertainment':
      return Icons.movie;
    case 'Education':
      return Icons.school;
    case 'Salary':
    case 'Gift':
    case 'Investment':
      return Icons.monetization_on;
    case 'Other':
      return Icons.category;
    default:
      return Icons.category;
  }
}
