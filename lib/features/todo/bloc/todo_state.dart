import 'package:equatable/equatable.dart';
import '../models/todo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ESTADOS
//
// Use `sealed class` para exaurir todos os casos com pattern matching.
// Cada estado representa uma "foto" completa da feature — não acumule estados
// em variáveis separadas (ex: isLoading + error + data). Um único objeto
// de estado é mais previsível e testável.
// ─────────────────────────────────────────────────────────────────────────────

sealed class TodoState extends Equatable {
  const TodoState();
}

/// Estado inicial antes de qualquer dado ser carregado.
final class TodoInitial extends TodoState {
  const TodoInitial();

  @override
  List<Object?> get props => [];
}

/// Dados sendo carregados (ex: fetch de API).
final class TodoLoading extends TodoState {
  const TodoLoading();

  @override
  List<Object?> get props => [];
}

/// Estado principal com a lista de tarefas e o filtro ativo.
final class TodoLoaded extends TodoState {
  final List<Todo> todos;
  final TodoFilter filter;

  const TodoLoaded({
    required this.todos,
    this.filter = TodoFilter.all,
  });

  /// Lista filtrada conforme o filtro ativo — computed a partir do estado.
  List<Todo> get filteredTodos {
    return switch (filter) {
      TodoFilter.all => todos,
      TodoFilter.active => todos.where((t) => !t.isCompleted).toList(),
      TodoFilter.completed => todos.where((t) => t.isCompleted).toList(),
    };
  }

  int get completedCount => todos.where((t) => t.isCompleted).length;
  int get activeCount => todos.where((t) => !t.isCompleted).length;
  bool get isEmpty => todos.isEmpty;

  TodoLoaded copyWith({List<Todo>? todos, TodoFilter? filter}) {
    return TodoLoaded(
      todos: todos ?? this.todos,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [todos, filter];

  @override
  String toString() =>
      'TodoLoaded(${todos.length} todos, filter: ${filter.name})';
}

/// Estado de erro com mensagem descritiva.
final class TodoError extends TodoState {
  final String message;
  const TodoError(this.message);

  @override
  List<Object?> get props => [message];
}