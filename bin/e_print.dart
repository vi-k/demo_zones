import 'dart:async';

/// Топик 5: Перехват и подмена функции [print].

void main() {
  runZoned(() {
    print('Hello World!');
  });

  runZoned(
    () {
      print('Hello World!');
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, msg) {
        parent.print(zone, '[APP] $msg');
      },
    ),
  );
}
