import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/service/biometric_service.dart';
import 'package:expense_tracker/core/theme/theme_cubit.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _budgetAlerts = true;
  bool _weeklySummary = true;
  bool _biometricLock = false;
  String _currency = 'USD';
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _showSaved() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved on this device.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final currentThemeMode = context.watch<ThemeCubit>().state;
    final currentThemeLabel = ThemeCubit.toLabel(currentThemeMode);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isAr ? 'الإعدادات' : 'Settings'),
        actions: [
          TextButton(onPressed: _showSaved, child: Text(isAr ? 'حفظ' : 'Save')),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              // ── Preferences ───────────────────────────────────────────────
              _SettingsSection(
                title: isAr ? 'التفضيلات' : 'Preferences',
                children: [
                  _OptionTile(
                    icon: Icons.payments_outlined,
                    title: isAr ? 'العملة' : 'Currency',
                    value: _currency,
                    onTap: () => _pickValue(
                      title: isAr ? 'العملة' : 'Currency',
                      values: const ['USD', 'EUR', 'GBP', 'SYP'],
                      current: _currency,
                      onChanged: (v) => setState(() => _currency = v),
                    ),
                  ),
                  _OptionTile(
                    icon: Icons.language_outlined,
                    title: isAr ? 'اللغة' : 'Language',
                    value: _language,
                    onTap: () => _pickValue(
                      title: isAr ? 'اللغة' : 'Language',
                      values: const ['English', 'Arabic'],
                      current: _language,
                      onChanged: (v) => setState(() => _language = v),
                    ),
                  ),
                  _OptionTile(
                    icon: _themeIcon(currentThemeMode),
                    title: isAr ? 'المظهر' : 'Appearance',
                    value: currentThemeLabel,
                    onTap: () => _pickValue(
                      title: isAr ? 'المظهر' : 'Appearance',
                      values: const ['System', 'Light', 'Dark'],
                      current: currentThemeLabel,
                      onChanged: (label) {
                        context.read<ThemeCubit>().setTheme(label);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Notifications ─────────────────────────────────────────────
              _SettingsSection(
                title: isAr ? 'التنبيهات' : 'Notifications',
                children: [
                  _SwitchTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: isAr ? 'تنبيهات الميزانية' : 'Budget alerts',
                    subtitle: isAr
                        ? 'نبهني عند الاقتراب من الحد'
                        : 'Warn me near spending limits',
                    value: _budgetAlerts,
                    onChanged: (v) => setState(() => _budgetAlerts = v),
                  ),
                  _SwitchTile(
                    icon: Icons.summarize_outlined,
                    title: isAr ? 'ملخص أسبوعي' : 'Weekly summary',
                    subtitle: isAr
                        ? 'تقرير مختصر عن نشاطك'
                        : 'A compact activity recap',
                    value: _weeklySummary,
                    onChanged: (v) => setState(() => _weeklySummary = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Security ──────────────────────────────────────────────────
              _SettingsSection(
                title: isAr ? 'الأمان' : 'Security',
                children: [
                  _SwitchTile(
                    icon: Icons.fingerprint,
                    title: isAr ? 'قفل بيومتري' : 'Biometric lock',
                    subtitle: isAr
                        ? 'اطلب التحقق عند فتح التطبيق'
                        : 'Require verification on app open',
                    value: _biometricLock,
                    // CHANGED: Use the handler instead of setState directly
                    onChanged: _handleBiometricToggle,
                  ),
                  _OptionTile(
                    icon: Icons.logout,
                    title: isAr ? 'تسجيل الخروج' : 'Sign out',
                    value: '',
                    destructive: true,
                    onTap: () {
                      context.read<AuthBloc>().add(SignOutRequested());
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/login', (route) => false);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                isAr
                    ? 'بعض الإعدادات محفوظة محلياً حالياً إلى أن يتم ربط ملف المستخدم.'
                    : 'Some settings are currently local until profile sync is connected.',
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _themeIcon(ThemeMode mode) => switch (mode) {
    ThemeMode.dark => Icons.dark_mode,
    ThemeMode.light => Icons.light_mode,
    ThemeMode.system => Icons.brightness_auto,
  };

  Future<void> _pickValue({
    required String title,
    required List<String> values,
    required String current,
    required ValueChanged<String> onChanged,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              for (final value in values)
                ListTile(
                  title: Text(value),
                  trailing: value == current
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(context, value),
                ),
            ],
          ),
        );
      },
    );

    if (selected != null) onChanged(selected);
  }

  Future<void> _loadSettings() async {
    final isEnabled = await BiometricService.isBiometricEnabled();
    if (mounted) setState(() => _biometricLock = isEnabled);
  }

  Future<void> _handleBiometricToggle(bool value) async {
    if (value) {
      final isSupported = await BiometricService.canCheckBiometrics();
      if (!isSupported) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometrics not available on this device'),
            ),
          );
          setState(() => _biometricLock = false);
        }
        return;
      }

      final authenticated = await BiometricService.authenticate();
      if (authenticated) {
        await BiometricService.setBiometricEnabled(true);
        if (mounted) setState(() => _biometricLock = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication failed. Feature not enabled.'),
            ),
          );
          setState(() => _biometricLock = false);
        }
      }
    } else {
      await BiometricService.setBiometricEnabled(false);
      if (mounted) setState(() => _biometricLock = false);
    }
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final bool destructive;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = destructive ? cs.error : cs.onSurface;
    return ListTile(
      leading: Icon(icon, color: destructive ? cs.error : cs.primary),
      title: Text(title, style: TextStyle(color: color)),
      trailing: value.isEmpty
          ? const Icon(Icons.chevron_right)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SwitchListTile(
      secondary: Icon(icon, color: cs.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      activeThumbColor: cs.primary,
      onChanged: onChanged,
    );
  }
}
