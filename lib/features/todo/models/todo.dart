import 'package:equatable/equatable.dart';

/// Enum para filtrar tarefas.
enum TodoFilter { all, active, completed }

extension TodoFilterLabel on TodoFilter {
  String get label {
    switch (this) {
      case TodoFilter.all:
        return 'Todas';
      case TodoFilter.active:
        return 'Ativas';
      case TodoFilter.completed:
        return 'Concluídas';
    }
  }
}

/// Modelo imutável de uma tarefa.
///
/// [Equatable] garante que dois objetos com os mesmos campos sejam considerados
/// iguais (==), o que é essencial para o BLoC detectar mudanças de estado.
class Todo extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  const Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });

  /// Cria uma cópia com campos opcionalmente alterados.
  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Equatable usa [props] para comparação e hashCode.
  @override
  List<Object?> get props => [id, title, isCompleted, createdAt];

  @override
  String toString() => 'Todo(id: $id, title: "$title", done: $isCompleted)';
}