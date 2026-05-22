import 'dart:async';

Future<void> main() async {
  // Пример 1: функция, переданная в `Future`, запускается в той же зоне, где
  // `Future` был создан.

  print('----- Future -----');

  late Future<void> future;

  void handleFuture() {
    print('${Zone.current['zone']}');
  }

  runZoned(() {
    future = Future(handleFuture);
  }, zoneValues: {'zone': 'zone 1'});

  await runZoned(() async {
    await future;
  }, zoneValues: {'zone': 'zone 2'});

  // Пример 2: функция обработки стрима запускается в зоне, где осуществляется
  // подписка на стрим.

  print('----- Stream -----');

  late Stream<int> stream;
  late Future<void> streamFuture;

  void handleStream(int value) {
    print('${Zone.current['zone']}: $value');
  }

  runZoned(() {
    final controller = StreamController<int>();
    stream = controller.stream;
    controller.add(1);
    controller.add(2);
    controller.add(3);
    streamFuture = controller.close();
  }, zoneValues: {'zone': 'zone 1'});

  runZoned(() {
    stream.listen(handleStream);
  }, zoneValues: {'zone': 'zone 2'});

  await streamFuture;

  // Пример 3: меняем поведение listen: запускаем функцию обработки в другой
  // зоне.

  print('----- ZonedStream -----');

  late Stream<int> stream2;
  late Future<void> streamFuture2;

  void handleStream2(int value) {
    print('${Zone.current['zone']}: $value');
  }

  runZoned(() {
    final controller = StreamController<int>();
    stream2 = ZonedStream(controller.stream, Zone.current);
    controller.add(1);
    controller.add(2);
    controller.add(3);
    streamFuture2 = controller.close();
  }, zoneValues: {'zone': 'zone 1'});

  runZoned(() {
    stream2.listen(handleStream2);
  }, zoneValues: {'zone': 'zone 2'});

  await streamFuture2;
}

/// Собственный класс стрима, позволяющий запускать обработчики стрима
/// в другой зоне.
class ZonedStream<T> extends StreamView<T> {
  final Stream<T> _stream;
  final Zone _zone;

  ZonedStream(this._stream, this._zone) : super(_stream);

  /// Суть переопределения в том, чтобы внутри метода listen все калбэки
  /// пропускать через зону.
  ///
  /// Важный момент: работа со стримом так или иначе всегда сводится к
  /// подписке на него, т.е. запуску метода [listen]. Но подмена зоны будет
  /// работать только при прямой подписке на [Stream]. Т.е., к примеру, при
  /// обработке стрима через `await for` код внутри цикла `for` будет
  /// выполнен в зоне, где происходит сам цикл, а не в той, где был
  /// создан [ZonedStream].
  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => _stream.listen(
    onData == null ? null : _zone.bindUnaryCallback(onData),
    onError: switch (onError) {
      null => null,
      final void Function(Object) _ => _zone.bindUnaryCallback(onError),
      final void Function(Object, StackTrace) _ => _zone.bindBinaryCallback(
        onError,
      ),
      _ =>
        throw ArgumentError.value(
          onError,
          'onError',
          'Error handler must accept one Object'
              ' or one Object and a StackTrace as arguments',
        ),
    },
    onDone: onDone == null ? null : _zone.bindCallback(onDone),
    cancelOnError: cancelOnError,
  );
}
