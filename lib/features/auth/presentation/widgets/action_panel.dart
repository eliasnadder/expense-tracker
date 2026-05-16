import 'package:expense_tracker/features/auth/presentation/widgets/profile_panel.dart';
import 'package:flutter/material.dart';

class ActionPanel extends StatelessWidget {
  final bool isAr;
  final VoidCallback onSettings;
  final VoidCallback onSignOut;

  const ActionPanel({
    required this.isAr,
    required this.onSettings,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return ProfilePanel(
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
