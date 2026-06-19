import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/counter_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS PRINCIPAIS DO flutter_bloc
//
//  BlocProvider   → cria e injeta o Bloc/Cubit na árvore de widgets
//  BlocBuilder    → reconstrói a UI quando o estado muda
//  BlocListener   → reage a mudanças de estado sem reconstruir (side effects)
//  BlocConsumer   → combina BlocBuilder + BlocListener
//  MultiBlocProvider → injeta múltiplos Blocs de uma vez
// ─────────────────────────────────────────────────────────────────────────────

/// Página raiz que PROVÊ o Cubit para a subárvore.
///
/// BlocProvider cria o cubit E faz o dispose automático quando o widget sai
/// da árvore — sem vazamentos de memória.
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: const CounterView(),
    );
  }
}

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cubit — Contador'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _StepSelector(),
            const SizedBox(height: 32),
            const _CounterDisplay(),
            const SizedBox(height: 32),
            const _CounterButtons(),
          ],
        ),
      ),
    );
  }
}

/// Exibe o valor atual. Usa [BlocBuilder] para reconstruir APENAS este widget
/// quando o count muda — granularidade fina de rebuild.
class _CounterDisplay extends StatelessWidget {
  const _CounterDisplay();

  @override
  Widget build(BuildContext context) {
    final count = context.select<CounterCubit, int>(
          (cubit) => cubit.state.count,
    );

    return Column(
      children: [
        Text(
          '$count',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: count < 0 ? Colors.red : Colors.green.shade700,
          ),
        ),
        Text(
          count == 0
              ? 'Neutro'
              : count > 0
              ? 'Positivo'
              : 'Negativo',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

/// Controles de step — ilustra [BlocBuilder] com [buildWhen] para otimização.
class _StepSelector extends StatelessWidget {
  const _StepSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterCubit, CounterState>(
      // buildWhen evita rebuilds desnecessários:
      // só reconstrói se stepSize mudou (ignora mudanças em count)
      buildWhen: (previous, current) => previous.stepSize != current.stepSize,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Passo: '),
            for (final step in [1, 5, 10])
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text('$step'),
                  selected: state.stepSize == step,
                  onSelected: (_) =>
                      context.read<CounterCubit>().changeStep(step),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Botões de ação. Usa [context.read] pois não precisa escutar o estado.
class _CounterButtons extends StatelessWidget {
  const _CounterButtons();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CounterCubit>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          heroTag: 'decrement',
          onPressed: cubit.decrement,
          tooltip: 'Decrementar',
          child: const Icon(Icons.remove),
        ),
        const SizedBox(width: 16),
        FloatingActionButton.extended(
          heroTag: 'reset',
          onPressed: cubit.reset,
          label: const Text('Reset'),
          icon: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          heroTag: 'increment',
          onPressed: cubit.increment,
          tooltip: 'Incrementar',
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}