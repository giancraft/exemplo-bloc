import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';
import '../models/todo.dart';
import 'todo_event.dart';
import 'todo_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BLOC COMPLETO
//
// Diferente do Cubit, o Bloc usa o padrão Event → Handler → State.
// Vantagens sobre o Cubit:
//   ✓ Melhor rastreabilidade (onTransition inclui o evento que causou a mudança)
//   ✓ Fácil debounce/throttle via EventTransformer (bloc_concurrency)
//   ✓ Mais escalável para features complexas
//   ✓ Logs e analytics nativos (qual evento disparou qual estado)
//
// Use Bloc quando:
//   • A lógica é complexa e tem muitas ramificações
//   • Precisa de transformações de evento (debounce, sequential, restartable)
//   • Quer rastreabilidade máxima para debugging
//
// Use Cubit quando:
//   • A lógica é simples (toggle, form, contador)
//   • Quer menos boilerplate
// ─────────────────────────────────────────────────────────────────────────────

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final _uuid = const Uuid();

  TodoBloc() : super(const TodoInitial()) {
    // Registra um handler para cada tipo de evento.
    // O Bloc garante que apenas um handler roda por vez por padrão (concurrent).
    on<TodoAdded>(_onTodoAdded);
    on<TodoToggled>(_onTodoToggled);
    on<TodoDeleted>(_onTodoDeleted);
    on<TodoFilterChanged>(_onFilterChanged);
    on<CompletedTodosCleared>(_onCompletedCleared);

    // Inicializa com alguns dados de exemplo
    _loadInitialData();
  }

  void _loadInitialData() {
    // Simula carregamento inicial (em produção: await repositorio.fetchAll())
    emit(
      TodoLoaded(
        todos: [
          Todo(
            id: _uuid.v4(),
            title: 'Estudar BLoC Pattern',
            isCompleted: true,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          Todo(
            id: _uuid.v4(),
            title: 'Implementar flutter_bloc',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          Todo(
            id: _uuid.v4(),
            title: 'Escrever testes com bloc_test',
            createdAt: DateTime.now(),
          ),
        ],
      ),
    );
  }

  /// Handler para [TodoAdded]: cria e adiciona uma nova tarefa.
  Future<void> _onTodoAdded(
      TodoAdded event,
      Emitter<TodoState> emit,
      ) async {
    // Proteção: só opera se já há dados carregados
    final current = state;
    if (current is! TodoLoaded) return;

    if (event.title.trim().isEmpty) return;

    // Simula delay de persistência (ex: salvar no banco)
    // await _repository.save(newTodo);

    final newTodo = Todo(
      id: _uuid.v4(),
      title: event.title.trim(),
      createdAt: DateTime.now(),
    );

    emit(current.copyWith(todos: [...current.todos, newTodo]));
  }

  /// Handler para [TodoToggled]: inverte o status de conclusão.
  void _onTodoToggled(TodoToggled event, Emitter<TodoState> emit) {
    final current = state;
    if (current is! TodoLoaded) return;

    final updatedTodos = current.todos.map((todo) {
      return todo.id == event.todoId
          ? todo.copyWith(isCompleted: !todo.isCompleted)
          : todo;
    }).toList();

    emit(current.copyWith(todos: updatedTodos));
  }

  /// Handler para [TodoDeleted]: remove a tarefa da lista.
  void _onTodoDeleted(TodoDeleted event, Emitter<TodoState> emit) {
    final current = state;
    if (current is! TodoLoaded) return;

    emit(
      current.copyWith(
        todos: current.todos.where((t) => t.id != event.todoId).toList(),
      ),
    );
  }

  /// Handler para [TodoFilterChanged]: atualiza o filtro ativo.
  void _onFilterChanged(TodoFilterChanged event, Emitter<TodoState> emit) {
    final current = state;
    if (current is! TodoLoaded) return;

    emit(current.copyWith(filter: event.filter));
  }

  /// Handler para [CompletedTodosCleared]: remove todas as tarefas concluídas.
  void _onCompletedCleared(
      CompletedTodosCleared event,
      Emitter<TodoState> emit,
      ) {
    final current = state;
    if (current is! TodoLoaded) return;

    emit(
      current.copyWith(
        todos: current.todos.where((t) => !t.isCompleted).toList(),
      ),
    );
  }

  @override
  void onTransition(Transition<TodoEvent, TodoState> transition) {
    super.onTransition(transition);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    // Centraliza tratamento de erros; o AppBlocObserver também captura isso.
    super.onError(error, stackTrace);
  }
}