import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'app.dart';
import 'observer/app_bloc_observer.dart';

void main() {
  // Registra o observer GLOBAL antes de qualquer Bloc/Cubit ser criado.
  Bloc.observer = const AppBlocObserver();

  runApp(const App());
}