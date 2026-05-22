import 'dart:async';

/// Топик 6: Перехват и подмена функции создания таймеров.

Future<void> main() async {
  // Пример 1: переопределив калбэк `createTimer`, мы можем управлять созданием
  // таймеров. Например, ускорять их.
  //
  // Для полноценной работы с таймерами нужно переопределить и
  // `createPeriodicTimer` (для периодических таймеров). Здесь мы этого не
  // делаем.

  print('----- Ускорение таймеров в 2 раза -----');

  final stopwatch = Stopwatch()..start();

  runZoned(
    () {
      print('Started...');

      Timer(Duration(seconds: 2), () {
        print('timer 2 sec');
      });

      Timer(Duration(seconds: 4), () {
        print('timer 4 sec');
      });
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        parent.print(zone, '${stopwatch.elapsed}: $line');
      },
      createTimer: (self, parent, zone, duration, f) {
        print('Created timer with duration: $duration');
        return parent.createTimer(zone, duration ~/ 2, f);
      },
    ),
  );

  await Future<void>.delayed(Duration(milliseconds: 2500));

  // Пример 2: нам вообще не обязательно создавать реальные таймеры. Мы можем
  // вернуть фейковые таймеры и эмулировать их работу вручную, как это делает
  // `fake_async`.
  //
  // Это полезно в тестах. Например, можно написать тесты для всего
  // приложения, просто передавая в функцию `elapse` нужные интервалы.
  //
  // Это базовый пример. Он не покрывает все случаи, но даёт понимание, как это
  // в принципе работает.

  print('----- fake_async -----');

  // Список собственных таймеров.
  final timers = <_MyTimer>[];

  // Фейковое "текущее" время. Его мы будем искусственно увеличивать через
  // функцию `elapse`. Без нашего вмешательства время идти не будет.
  var now = Duration.zero;

  runZoned(
    () {
      print('Started...');

      Timer(Duration(seconds: 2), () {
        print('timer 2 sec');
      });

      Timer(Duration(minutes: 2), () {
        print('timer 2 min');
      });

      // При создании `Future` через `Future.delayed()` и `Future()` так же
      // создаётся таймер. Поэтому, перехватывая `createTimer` мы перехватываем
      // и `Future`, создаваемые через конструкторы.
      //
      // Важный момент: `Future`, создаваемые как результат вызова `async`
      // методов, через `createTimer` мы перехватить не можем. Не может этого
      // и `fake_async`.
      Future.delayed(Duration(hours: 2), () {
        print('timer 2 hour');
      });
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        parent.print(zone, '$now: $line');
      },
      createTimer: (self, parent, zone, duration, f) {
        print('Created timer with duration: $duration');
        // Создаём фейковый таймер и возвращаем его пользователю.
        // Он не будет знать, что это фейковый таймер.
        final timer = _MyTimer(now + duration, f);
        timers.add(timer);
        return timer;
      },
    ),
  );

  void elapse(Duration duration) {
    now += duration;

    // Удаляем отменённые таймеры.
    timers.removeWhere((timer) => !timer.isActive);

    // Ищем таймеры, которые должны были сработать.
    final fired = <_MyTimer>[];
    for (final timer in timers) {
      if (now >= timer.fire) {
        fired.add(timer);
      }
    }

    if (fired.isEmpty) {
      print('<no timers fired>');
      return;
    }

    fired.sort((a, b) => a.fire.compareTo(b.fire));

    for (final timer in fired) {
      timer.callback?.call();
      timers.remove(timer);
    }
  }

  // Увеличиваем "время" на 1 сек: ни один таймер не сработает.
  print('elapse 1 sec');
  elapse(Duration(seconds: 1));

  // Увеличиваем "время" ещё на 1 сек: сработает 2-секундный таймер.
  print('elapse 1 sec');
  elapse(Duration(seconds: 1));

  // Увеличиваем "время" до 2 мин: сработает 2-минутный таймер.
  print('elapse 1 min 58 sec');
  elapse(Duration(minutes: 1, seconds: 58));

  // Увеличиваем "время" до 2 часов: сработает 2-часовой таймер.
  print('elapse 1 hour 58 min');
  elapse(Duration(hours: 1, minutes: 58));
}

/// Фейковый таймер.
class _MyTimer implements Timer {
  // Нас не интересует длительность таймера, нас интересует только время
  // его срабатывания.
  final Duration fire;

  final void Function()? callback;

  bool _isActive = true;

  _MyTimer(this.fire, [this.callback]);

  @override
  int get tick => 0;

  @override
  bool get isActive => _isActive;

  @override
  void cancel() {
    _isActive = false;
  }
}
