import 'dart:async';

/// Топик 2: Обработка ошибок в зоне.
///
/// Для отлова необработанных ошибок в зоне используется [runZonedGuarded]. Это
/// тот же [runZoned], но c дополнительным обязательным параметром onError.
///
/// Забегая вперёд: в реальности для отлова таких ошибок используется
/// [ZoneSpecification.handleUncaughtError].

void main() {
  runZonedGuarded(
    () {
      print('Hello World!');
      throw Exception('Error from zone');
    },
    (error, stackTrace) {
      print('Error: $error');
      print('Stack trace: $stackTrace');
    },
  );
}
