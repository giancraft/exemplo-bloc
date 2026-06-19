import 'package:bloc/bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CUBIT
//
// Cubit é a forma mais simples do BLoC.
// Em vez de dispatchar Eventos, você chama métodos diretamente.
// Ideal para lógicas simples como contador, toggle, form.
//
// Analogia com soluções leves:
//   • watch_it  → ValueNotifier + GetIt
//   • Signals   → Signal<int> com computed/effect
//   • Cubit     → classe gerenciável + Stream reativo
// ─────────────────────────────────────────────────────────────────────────────

/// Estado do contador encapsulado em um objeto (facilita extensão futura).
///
/// Poderíamos usar [int] diretamente, mas um objeto separado é uma boa prática:
/// permite adicionar campos como `history`, `min`, `max` sem quebrar a API.
class CounterState {
  final int count;
  final int stepSize;

  const CounterState({
    required this.count,
    this.stepSize = 1,
  });

  CounterState copyWith({int? count, int? stepSize}) {
    return CounterState(
      count: count ?? this.count,
      stepSize: stepSize ?? this.stepSize,
    );
  }

  @override
  String toString() => 'CounterState(count: $count, stepSize: $stepSize)';
}

/// Cubit que gerencia o estado de um contador com step configurável.
class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(const CounterState(count: 0));

  /// Incrementa o contador pelo [stepSize] atual.
  void increment() => emit(state.copyWith(count: state.count + state.stepSize));

  /// Decrementa o contador pelo [stepSize] atual.
  void decrement() => emit(state.copyWith(count: state.count - state.stepSize));

  /// Reseta o contador para zero.
  void reset() => emit(state.copyWith(count: 0));

  /// Altera o passo de incremento/decremento.
  void changeStep(int newStep) {
    if (newStep < 1) return; // guarda de segurança
    emit(state.copyWith(stepSize: newStep));
  }
}