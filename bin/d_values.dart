import 'dart:async';

/// Топик 4: Создание контекста для асинхронного кода.

Future<void> main() async {
  // Пример 1.

  print('----- Разные значения в разных зонах -----');

  runZoned(() {
    printZonedValue();
  }, zoneValues: {'value': 123});

  runZoned(() {
    printZonedValue();
  }, zoneValues: {'value': 'abc'});

  // Пример 2.

  print('----- Передача traceId в функцию логирования -----');

  // Без идентификатора.
  log('Hello World!');

  runZoned(() {
    log('Hello World!');
  }, zoneValues: {'traceId': 1});

  runZoned(() {
    asyncTraceIdDemo();
  }, zoneValues: {'traceId': 2});

  await Future.delayed(Duration(seconds: 1));

  // Пример 2.

  print('----- Тестовое окружение -----');

  // Рабочий запуск.
  someFeature();

  // Запуск в тестовом окружении.
  runZoned(() {
    someFeature();
  }, zoneValues: {'is_testing': true});
}

void printZonedValue() {
  final value = Zone.current['value'];
  print(value);
}

Future<void> asyncTraceIdDemo() async {
  await Future.delayed(Duration(milliseconds: 300));

  Timer(Duration(milliseconds: 300), () {
    log('Hello World!');
  });
}

void log(String msg) {
  final traceId = Zone.current['traceId'];
  print('${traceId == null ? '' : '($traceId) '}$msg');
}

void someFeature() {
  final isTesting = Zone.current['is_testing'] ?? false;
  if (isTesting) {
    print('Test mode ON');
  } else {
    print('Test mode OFF');
  }
}
