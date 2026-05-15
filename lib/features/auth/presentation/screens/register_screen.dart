import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController();
  late final _emailController = TextEditingController();
  late final _passwordController = TextEditingController();
  late final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: colors.onSurfaceVariant, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: colors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.app_registration,
                        color: colors.onPrimaryContainer,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isAr ? 'إنشاء حساب' : 'Create Account',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAr
                          ? 'انضم إلى Financial Hub لإدارة ثروتك.'
                          : 'Join Financial Hub to manage your wealth.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    _buildField(
                      label: isAr ? 'الاسم الكامل' : 'Full Name',
                      hint: 'John Doe',
                      icon: Icons.person_outline,
                      controller: _nameController,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return isAr ? 'الاسم مطلوب' : 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildField(
                      label: isAr ? 'البريد الإلكتروني' : 'Email Address',
                      hint: 'example@mail.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      validator: (value) {
                        final email = (value ?? '').trim();
                        if (email.isEmpty) {
                          return isAr
                              ? 'البريد الإلكتروني مطلوب'
                              : 'Email is required';
                        }
                        if (!email.contains('@')) {
                          return isAr
                              ? 'البريد الإلكتروني غير صالح'
                              : 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildField(
                      label: isAr ? 'كلمة المرور' : 'Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      controller: _passwordController,
                      validator: (value) {
                        if ((value ?? '').length < 6) {
                          return isAr
                              ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                              : 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: colors.onSurfaceVariant,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildField(
                      label: isAr ? 'تأكيد كلمة المرور' : 'Confirm Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return isAr
                              ? 'كلمتا المرور غير متطابقتين'
                              : 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (v) =>
                              setState(() => _agreeToTerms = v ?? false),
                          activeColor: colors.primary,
                        ),
                        Expanded(
                          child: Text(
                            isAr
                                ? 'أوافق على شروط الخدمة وسياسة الخصوصية.'
                                : 'I agree to the Terms of Service and Privacy Policy.',
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() &&
                              _agreeToTerms) {
                            context.read<AuthBloc>().add(
                              EmailSignUpRequested(
                                _emailController.text.trim(),
                                _passwordController.text,
                                _nameController.text.trim(),
                              ),
                            );
                          } else if (!_agreeToTerms) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isAr
                                      ? 'يجب الموافقة على الشروط أولاً'
                                      : 'Accept the terms first',
                                ),
                                backgroundColor: colors.primary,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          isAr ? 'إنشاء حساب' : 'Sign Up',
                          style: textTheme.labelLarge?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isAr
                              ? 'لديك حساب بالفعل؟'
                              : 'Already have an account?',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            isAr ? 'تسجيل الدخول' : 'Log In',
                            style: textTheme.labelLarge?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
