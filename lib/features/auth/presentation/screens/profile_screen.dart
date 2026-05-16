import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/screens/settings_screen.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/action_panel.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/profiel_header.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/profile_panel.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/profile_row.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(isAr ? 'الملف الشخصي' : 'Profile')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState is AuthAuthenticated ? authState.user : null;

          return BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (context, expenseState) {
              final expenses = expenseState is ExpenseLoaded
                  ? expenseState.expenses
                  : const [];
              final transactions = expenses.length;

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  ProfileHeader(
                    name: user?.displayName ?? (isAr ? 'مستخدم' : 'User'),
                    email: user?.email ?? '',
                    photoUrl: user?.photoUrl,
                    isAr: isAr,
                  ),
                  const SizedBox(height: 16),
                  ProfilePanel(
                    children: [
                      ProfileRow(
                        icon: Icons.receipt_long_outlined,
                        title: isAr ? 'المعاملات' : 'Transactions',
                        value: NumberFormat.decimalPattern().format(
                          transactions,
                        ),
                      ),
                      ProfileRow(
                        icon: Icons.payments_outlined,
                        title: isAr ? 'العملة' : 'Currency',
                        value: user?.currency ?? 'USD',
                      ),
                      ProfileRow(
                        icon: Icons.language_outlined,
                        title: isAr ? 'اللغة' : 'Language',
                        value: user?.language.toUpperCase() ?? 'EN',
                      ),
                      ProfileRow(
                        icon: Icons.dark_mode_outlined,
                        title: isAr ? 'المظهر' : 'Theme',
                        value: user?.theme ?? 'system',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ActionPanel(
                    isAr: isAr,
                    onSettings: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    onSignOut: () {
                      context.read<AuthBloc>().add(SignOutRequested());
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/login', (route) => false);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isAr
                        ? 'يتم تحديث أرقام هذا الشهر من معاملاتك الحالية.'
                        : 'Monthly figures update from your current transactions.',
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
