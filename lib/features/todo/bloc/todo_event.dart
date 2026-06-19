import 'package:equatable/equatable.dart';
import '../models/todo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EVENTOS
//
// Em um Bloc completo (ao contrário do Cubit), EVENTOS são a única forma de
// comunicação com o Bloc. A UI nunca chama métodos diretamente — ela dispatcha
// eventos (bloc.add(AlgumEvento())).
//
// Use `sealed class` (Dart 3+) para garantir que todos os casos sejam
// tratados via pattern matching no bloc.
// ─────────────────────────────────────────────────────────────────────────────

sealed class TodoEvent extends Equatable {
  const TodoEvent();
}

/// Solicitação para adicionar uma nova tarefa.
final class TodoAdded extends TodoEvent {
  final String title;
  const TodoAdded(this.title);

  @override
  List<Object?> get props => [title];
}

/// Alterna o status de conclusão de uma tarefa (toggle).
final class TodoToggled extends TodoEvent {
  final String todoId;
  const TodoToggled(this.todoId);

  @override
  List<Object?> get props => [todoId];
}

/// Remove uma tarefa da lista.
final class TodoDeleted extends TodoEvent {
  final String todoId;
  const TodoDeleted(this.todoId);

  @override
  List<Object?> get props => [todoId];
}

/// Altera o filtro ativo (todas / ativas / concluídas).
final class TodoFilterChanged extends TodoEvent {
  final TodoFilter filter;
  const TodoFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Remove todas as tarefas concluídas.
final class CompletedTodosCleared extends TodoEvent {
  const CompletedTodosCleared();

  @override
  List<Object?> get props => [];
}