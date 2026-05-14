import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/core/service/gemini_service.dart';
import 'package:expense_tracker/core/service/notification_service.dart';
import 'package:expense_tracker/features/ai_insight/presentation/bloc/ai_bloc.dart';
import 'package:expense_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:expense_tracker/features/budget/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // External
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  getIt.registerSingleton(GoogleSignIn.instance);

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: getIt(),
      googleSignIn: getIt(),
      firestore: getIt(),
    ),
  );

  // Expense Repository
  getIt.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(firestore: getIt()),
  );
  getIt.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(firestore: getIt()),
  );

  getIt.registerLazySingleton(() => GeminiService());

  getIt.registerLazySingleton(() => NotificationService());

  // Blocs
  getIt.registerFactory(() => AuthBloc(authRepository: getIt()));
  getIt.registerFactory(() => ExpenseBloc(expenseRepository: getIt()));
  getIt.registerFactory(() => BudgetBloc(budgetRepository: getIt()));
  getIt.registerFactory(() => AiBloc(geminiService: getIt()));
}
