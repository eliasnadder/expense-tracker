import 'package:expense_tracker/core/service/gemini_service.dart';
import 'package:expense_tracker/features/ai_insight/presentation/bloc/ai_event.dart';
import 'package:expense_tracker/features/ai_insight/presentation/bloc/ai_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AiBloc extends Bloc<AiEvent, AiState> {
  final GeminiService geminiService;

  AiBloc({required this.geminiService}) : super(AiInitial()) {
    on<AnalyzeExpenses>(_onAnalyze);
  }

  Future<void> _onAnalyze(AnalyzeExpenses event, Emitter<AiState> emit) async {
    if (event.expenses.isEmpty) {
      emit(AiLoaded(event.isAr 
          ? 'لا توجد معاملات كافية للتحليل.' 
          : 'Not enough transactions for analysis.'));
      return;
    }
    emit(AiLoading());
    try {
      final insight = await geminiService.analyzeExpenses(
        expenses: event.expenses,
        budget: event.budget,
        isAr: event.isAr,
      );
      emit(AiLoaded(insight));
    } catch (e) {
      emit(AiError(e.toString()));
    }
  }
}
