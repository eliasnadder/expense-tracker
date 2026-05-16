import 'package:expense_tracker/components/loading_ind/loading_indicator.dart';
import 'package:expense_tracker/core/service/biometric_service.dart';
import 'package:flutter/material.dart';

class BiometricGateScreen extends StatefulWidget {
  const BiometricGateScreen({super.key});

  @override
  State<BiometricGateScreen> createState() => _BiometricGateScreenState();
}

class _BiometricGateScreenState extends State<BiometricGateScreen> {
  bool _isLoading = true;
  bool _authFailed = false;

  @override
  void initState() {
    super.initState();
    _handleAuthentication();
  }

  Future<void> _handleAuthentication() async {
    final isEnabled = await BiometricService.isBiometricEnabled();

    // Biometrics disabled → continue normally
    if (!isEnabled) {
      _goToAuth();
      return;
    }

    final authenticated = await BiometricService.authenticate();

    if (!mounted) return;

    if (authenticated) {
      _goToAuth();
    } else {
      setState(() {
        _isLoading = false;
        _authFailed = true;
      });
    }
  }

  void _goToAuth() {
    Navigator.pushReplacementNamed(context, '/auth');
  }

  Future<void> _retry() async {
    setState(() {
      _isLoading = true;
      _authFailed = false;
    });

    await _handleAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isLoading
                  ? Column(
                      key: const ValueKey('loading'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Icon(
                            Icons.fingerprint,
                            size: 52,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Verifying Identity',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Authenticate to access your expenses',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),
                        LoadingIndicator(),
                      ],
                    )
                  : Column(
                      key: const ValueKey('failed'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            size: 52,
                            color: colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Authentication Failed',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Unable to verify your identity.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),
                        FilledButton.icon(
                          onPressed: _retry,
                          icon: const Icon(Icons.fingerprint),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
