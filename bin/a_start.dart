import 'dart:async';

/// Топик 1: Введение в зоны.
///
/// Основной метод для создания собственной зоны и запуска в ней кода:
/// [runZoned].

void main() {
  print('----- Root zone -----');

  // Zone.root - корневая зона.
  // Zone.current - текущая зона.
  // Здесь они равны, так как мы в корневой зоне.
  print(Zone.current == Zone.root);

  // У корневой зоны нет родителя.
  print(Zone.current.parent);

  runZoned(() {
    print('----- Nested zone -----');
    // А здесь текущая и корневая зоны не равны.
    print(Zone.current == Zone.root);
    // Родителем является корневая зона.
    print(Zone.current.parent);

    runZoned(() {
      print('----- Nested zone 2 -----');
      print(Zone.current == Zone.root);
      // Родителем является предыдущая вложенная зона.
      print(Zone.current.parent);

      // Ошибка, если возникнет, вылетит за пределы зоны, т.е. в нашем
      // случае не будет обработана.
      print('----- Throws error -----');
      throw Exception('Error from zone');
    });
  });
}
