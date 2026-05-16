import 'package:expense_tracker/components/loading_ind/loading_indicator.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class GoogleSignInButton extends StatefulWidget {
  final bool isLoading;

  const GoogleSignInButton({required this.isLoading});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  Future<void> handleTap() async {
    if (widget.isLoading) return;
    try {
      context.read<AuthBloc>().add(GoogleSignInRequested());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: widget.isLoading
            ? null
            : () {
                handleTap();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 2,
          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
          ),
        ),
        child: widget.isLoading
            ? SizedBox(width: 24, height: 24, child: LoadingIndicator(size: 20))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/google.svg',
                    height: 24,
                    width: 24,
                    placeholderBuilder: (context) =>
                        const Icon(Icons.public, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Continue with Google',
                    style: textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
