import 'dart:async';

/// Топик 3: Обработка асинхронных ошибок в зоне.
///
/// Для обработки ошибок в зоне используется [runZonedGuarded] - это тот же
/// [runZoned], но c дополнительным обязательным параметром onError.

Future<void> main() async {
  // Пример 1: ошибка никогда не будет поймана, т.к. нет ожидания вызова
  // throwInAsync().

  // Чтобы перейти к следующему примеру, закомментируй этот пример или добавь
  // `await` перед `throwInAsync()`

  print('----- Unawaited exception -----');

  try {
    return throwInAsync();
  } on Object catch (e, s) {
    print('Error: $e');
    print('Stack trace: $s');
  }

  // Пример 2: runZonedGuarded позволяет перехватывать любые асинхронные
  // ошибки.

  runZonedGuarded(
    () {
      throwInAsync();
    },
    (error, stackTrace) {
      print('Error: $error');
      print('Stack trace: $stackTrace');
    },
  );

  // Пример 3: зависание зоны. Проблема этого кода: ошибка в Future
  // перехватывается зоной и успешно обрабатывается, но `await throwInAsync()`
  // обязан вернуть значение или выкинуть ошибку. Без этого await никогда
  // не завершится. Соответственно, и весь `runZonedGuarded` не завершится.
  // Код "зависает".
  //
  // Но на самом деле это плохой вариант использования `runZonedGuarded`.
  // `runZonedGuarded` не заменяет обычный try/catch.
  try {
    await runZonedGuarded(
      () async {
        print('Hello World!');
        await throwInAsync();
      },
      (error, stackTrace) {
        print('Error: $error');
        print('Stack trace: $stackTrace');
      },
    );
  } finally {
    print('Bye bye...');
  }
  print('Bye bye...');
}

Future<void> throwInAsync() async {
  await Future.delayed(Duration(milliseconds: 300), () {
    throw Exception('Async error from zone');
  });
}
