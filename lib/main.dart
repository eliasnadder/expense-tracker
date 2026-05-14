import 'package:expense_tracker/core/di/injection.dart';
import 'package:expense_tracker/core/service/notification_service.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_cubit.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:expense_tracker/features/auth/presentation/screens/splash_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/login_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/register_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/profile_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/settings_screen.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_event.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_event.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/categories_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupDependencies();
  await getIt<NotificationService>().initialize();
  await getIt<GoogleSignIn>().initialize();

  // Load saved theme before the first frame
  final themeCubit = ThemeCubit();
  await themeCubit.load();

  runApp(MyApp(themeCubit: themeCubit));
}

class MyApp extends StatelessWidget {
  final ThemeCubit themeCubit;
  const MyApp({super.key, required this.themeCubit});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: themeCubit),
        BlocProvider(
          create: (_) => getIt<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider(create: (_) => getIt<ExpenseBloc>()),
        BlocProvider(create: (_) => getIt<BudgetBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.read<ExpenseBloc>().add(LoadExpenses(state.user.id));
            context.read<BudgetBloc>().add(LoadBudgets(state.user.id));
          }
        },
        // BlocBuilder on ThemeCubit so the whole app rebuilds on theme change
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Expense Tracker',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('ar')],
              initialRoute: '/',
              routes: {
                '/': (context) => const SplashScreen(),
                '/auth': (context) => const AuthWrapper(),
                '/onboarding': (context) => const OnboardingScreen(),
                '/login': (context) => const LoginScreen(),
                '/register': (context) => const RegisterScreen(),
                '/profile': (context) => const ProfileScreen(),
                '/settings': (context) => const SettingsScreen(),
                '/categories': (context) => const CategoriesScreen(),
              },
            );
          },
        ),
      ),
    );
  }
}
