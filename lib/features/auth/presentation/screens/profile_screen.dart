import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/screens/settings_screen.dart';
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
              final monthlyIncome = expenseState is ExpenseLoaded
                  ? expenseState.totalIncome
                  : 0.0;
              final monthlySpent = expenseState is ExpenseLoaded
                  ? expenseState.totalExpenses
                  : 0.0;
              final transactions = expenses.length;

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _ProfileHeader(
                    name: user?.displayName ?? (isAr ? 'مستخدم' : 'User'),
                    email: user?.email ?? '',
                    photoUrl: user?.photoUrl,
                    isAr: isAr,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          label: isAr ? 'دخل الشهر' : 'Income',
                          value: _money(monthlyIncome),
                          icon: Icons.arrow_upward,
                          color: AppColors.income,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          label: isAr ? 'مصروف الشهر' : 'Spent',
                          value: _money(monthlySpent),
                          icon: Icons.arrow_downward,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ProfilePanel(
                    children: [
                      _ProfileRow(
                        icon: Icons.receipt_long_outlined,
                        title: isAr ? 'المعاملات' : 'Transactions',
                        value: NumberFormat.decimalPattern().format(
                          transactions,
                        ),
                      ),
                      _ProfileRow(
                        icon: Icons.payments_outlined,
                        title: isAr ? 'العملة' : 'Currency',
                        value: user?.currency ?? 'USD',
                      ),
                      _ProfileRow(
                        icon: Icons.language_outlined,
                        title: isAr ? 'اللغة' : 'Language',
                        value: user?.language.toUpperCase() ?? 'EN',
                      ),
                      _ProfileRow(
                        icon: Icons.dark_mode_outlined,
                        title: isAr ? 'المظهر' : 'Theme',
                        value: user?.theme ?? 'system',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ActionPanel(
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

  String _money(double amount) => '\$${NumberFormat('#,##0').format(amount)}';
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final bool isAr;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withValues(alpha: 0.16),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
            child: photoUrl == null
                ? Text(
                    name.isNotEmpty ? name.characters.first.toUpperCase() : 'U',
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    isAr ? 'حساب نشط' : 'Active account',
                    style: textTheme.labelMedium?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(label, style: textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  final List<Widget> children;

  const _ProfilePanel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  final bool isAr;
  final VoidCallback onSettings;
  final VoidCallback onSignOut;

  const _ActionPanel({
    required this.isAr,
    required this.onSettings,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return _ProfilePanel(
      children: [
        ListTile(
          leading: Icon(
            Icons.settings_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(isAr ? 'الإعدادات' : 'Settings'),
          subtitle: Text(
            isAr
                ? 'العملة، اللغة، التنبيهات، والأمان'
                : 'Currency, language, alerts, and security',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onSettings,
        ),
      ],
    );
  }
}
