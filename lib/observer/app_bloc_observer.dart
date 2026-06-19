import 'package:bloc/bloc.dart';

/// Observer global que intercepta TODOS os Blocs/Cubits da aplicação.
///
/// Ideal para logging, analytics e debugging. Registre-o em main() com:
///   Bloc.observer = AppBlocObserver();
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  /// Chamado quando qualquer Bloc ou Cubit é criado.
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    _log('onCreate', bloc.runtimeType);
  }

  /// Chamado quando um evento é adicionado a um Bloc (não se aplica a Cubits).
  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    _log('onEvent', bloc.runtimeType, detail: '$event');
  }

  /// Chamado ANTES de qualquer mudança de estado (Bloc e Cubit).
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _log(
      'onChange',
      bloc.runtimeType,
      detail: '\n  current: ${change.currentState}'
          '\n  next:    ${change.nextState}',
    );
  }

  /// Chamado após processamento de evento em um Bloc (contém current, event e next).
  @override
  void onTransition(
      Bloc<dynamic, dynamic> bloc,
      Transition<dynamic, dynamic> transition,
      ) {
    super.onTransition(bloc, transition);
    _log(
      'onTransition',
      bloc.runtimeType,
      detail: '\n  event:   ${transition.event}'
          '\n  current: ${transition.currentState}'
          '\n  next:    ${transition.nextState}',
    );
  }

  /// Chamado quando ocorre qualquer erro em Bloc ou Cubit.
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _log('onError', bloc.runtimeType, detail: '$error');
    super.onError(bloc, error, stackTrace);
  }

  /// Chamado quando um Bloc ou Cubit é fechado (dispose).
  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    _log('onClose', bloc.runtimeType);
  }

  void _log(String event, Type blocType, {String? detail}) {
    // ignore: avoid_print
    print('[$event] $blocType${detail != null ? " $detail" : ""}');
  }
}