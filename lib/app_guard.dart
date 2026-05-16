// app_guard.dart
import 'package:expense_tracker/core/service/biometric_service.dart';
import 'package:flutter/material.dart';

class AppGuard extends StatefulWidget {
  final Widget child;
  const AppGuard({required this.child, super.key});

  @override
  State<AppGuard> createState() => _AppGuardState();
}

class _AppGuardState extends State<AppGuard> {
  late final Future<bool> _enabledFuture;
  Future<bool>? _authFuture;

  @override
  void initState() {
    super.initState();
    _enabledFuture = BiometricService.isBiometricEnabled().then((enabled) {
      if (enabled) {
        _authFuture = BiometricService.authenticate();
      }
      return enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _enabledFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        if (!snapshot.data!) return widget.child;

        return FutureBuilder<bool>(
          future: _authFuture,
          builder: (context, auth) {
            if (auth.connectionState != ConnectionState.done)
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            if (auth.data == true) return widget.child;
            // Auth failed — show a retry button instead of a blank screen
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 64),
                    const SizedBox(height: 16),
                    const Text('Authentication required'),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Try Again'),
                      onPressed: () => setState(() {
                        _authFuture = BiometricService.authenticate();
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}