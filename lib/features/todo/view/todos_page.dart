import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../models/todo.dart';

/// Página raiz que provê o [TodoBloc] para a subárvore.
class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // lazy: true (padrão) → cria o Bloc apenas quando é acessado pela 1ª vez
      // lazy: false         → cria imediatamente (útil quando precisa de dados logo)
      create: (_) => TodoBloc(),
      child: const TodosView(),
    );
  }
}

class TodosView extends StatelessWidget {
  const TodosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloc — Lista de Tarefas'),
        centerTitle: true,
        actions: [
          // BlocBuilder apenas para o badge de contagem
          BlocBuilder<TodoBloc, TodoState>(
            buildWhen: (p, c) {
              // Só reconstrói quando a contagem de pendentes muda
              if (p is TodoLoaded && c is TodoLoaded) {
                return p.activeCount != c.activeCount;
              }
              return true;
            },
            builder: (context, state) {
              if (state is! TodoLoaded || state.activeCount == 0) {
                return const SizedBox.shrink();
              }
              return Chip(
                label: Text('${state.activeCount} pendente(s)'),
                visualDensity: VisualDensity.compact,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ── BlocConsumer = BlocBuilder + BlocListener juntos ──────────────────
      //
      //   builder  → reconstrói a UI (como BlocBuilder)
      //   listener → side effects: SnackBars, navegação, dialogs, etc.
      //   listenWhen / buildWhen → filtram quando cada callback é chamado
      body: BlocConsumer<TodoBloc, TodoState>(
        // listenWhen: só ouve se passou de Loaded para Loaded (mudança de dados)
        listenWhen: (previous, current) =>
        previous is TodoLoaded && current is TodoLoaded,
        listener: (context, state) {
          // Exemplo de side effect: mostrar snackbar quando lista fica vazia
          if (state is TodoLoaded && state.todos.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 Todas as tarefas foram removidas!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            TodoInitial() => const Center(child: Text('Inicializando...')),
            TodoLoading() => const Center(child: CircularProgressIndicator()),
            TodoError(:final message) => _ErrorView(message: message),
            TodoLoaded() => _LoadedView(state: state),
          };
        },
      ),

      floatingActionButton: const _AddTodoButton(),
    );
  }
}

// ── Estados visuais ─────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  final TodoLoaded state;
  const _LoadedView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FilterBar(activeFilter: state.filter),
        _StatsRow(state: state),
        const Divider(height: 1),
        Expanded(
          child: state.filteredTodos.isEmpty
              ? const _EmptyState()
              : ListView.builder(
            itemCount: state.filteredTodos.length,
            itemBuilder: (context, index) {
              return _TodoItem(todo: state.filteredTodos[index]);
            },
          ),
        ),
        if (state.completedCount > 0) const _ClearCompletedButton(),
      ],
    );
  }
}

// ── Componentes ─────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final TodoFilter activeFilter;
  const _FilterBar({required this.activeFilter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SegmentedButton<TodoFilter>(
        segments: TodoFilter.values
            .map(
              (f) => ButtonSegment(
            value: f,
            label: Text(f.label),
          ),
        )
            .toList(),
        selected: {activeFilter},
        onSelectionChanged: (selected) {
          // Dispatcha evento — a UI nunca conhece a lógica
          context.read<TodoBloc>().add(TodoFilterChanged(selected.first));
        },
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final TodoLoaded state;
  const _StatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatChip(
            label: 'Total',
            count: state.todos.length,
            color: Colors.blue,
            textTheme: textTheme,
          ),
          _StatChip(
            label: 'Pendentes',
            count: state.activeCount,
            color: Colors.orange,
            textTheme: textTheme,
          ),
          _StatChip(
            label: 'Concluídas',
            count: state.completedCount,
            color: Colors.green,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final TextTheme textTheme;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: textTheme.labelSmall),
      ],
    );
  }
}

class _TodoItem extends StatelessWidget {
  final Todo todo;
  const _TodoItem({required this.todo});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.red,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        // Dispatcha evento de deleção
        context.read<TodoBloc>().add(TodoDeleted(todo.id));
      },
      child: CheckboxListTile(
        value: todo.isCompleted,
        onChanged: (_) {
          context.read<TodoBloc>().add(TodoToggled(todo.id));
        },
        title: Text(
          todo.title,
          style: TextStyle(
            decoration:
            todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          _formatDate(todo.createdAt),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return 'há ${diff.inDays}d';
    if (diff.inHours > 0) return 'há ${diff.inHours}h';
    return 'agora mesmo';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checklist, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Nenhuma tarefa aqui.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ClearCompletedButton extends StatelessWidget {
  const _ClearCompletedButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextButton.icon(
        onPressed: () {
          context.read<TodoBloc>().add(const CompletedTodosCleared());
        },
        icon: const Icon(Icons.cleaning_services, color: Colors.red),
        label: const Text(
          'Limpar concluídas',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}

/// FAB que abre um dialog para adicionar nova tarefa.
class _AddTodoButton extends StatelessWidget {
  const _AddTodoButton();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddDialog(context),
      child: const Icon(Icons.add),
    );
  }

  void _showAddDialog(BuildContext context) {
    // Captura o bloc ANTES do async gap (boas práticas)
    final bloc = context.read<TodoBloc>();
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nova Tarefa'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Ex: Estudar bloc_concurrency...',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              bloc.add(TodoAdded(value));
              Navigator.of(dialogContext).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                bloc.add(TodoAdded(controller.text));
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }
}