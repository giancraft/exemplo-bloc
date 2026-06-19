import 'package:flutter/material.dart';
import 'features/counter/view/counter_page.dart';
import 'features/todo/view/todos_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLoC Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const _HomeShell(),
    );
  }
}

/// Shell de navegação entre as duas demos.
class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _selectedIndex = 0;

  static const _pages = <Widget>[
    CounterPage(), // Demo 1: Cubit
    TodosPage(),   // Demo 2: Bloc completo
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.exposure),
            label: 'Cubit',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_rtl),
            label: 'Bloc',
          ),
        ],
      ),
    );
  }
}