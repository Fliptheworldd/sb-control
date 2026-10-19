import 'dart:async';

/// GATT requests are serialized. Invalidating a connection cancels queued work.
/// In-flight OS operations cannot be cancelled; callers check the generation
/// before applying results and never retry an actuator command automatically.
class SerialQueue {
  Future<void> _tail = Future.value();
  int _generation = 0;
  int get generation => _generation;
  void invalidate() {
    _generation++;
  }

  bool isCurrent(int token) => token == _generation;
  Future<T> run<T>(Future<T> Function() action) {
    final token = _generation;
    final result = _tail.then((_) {
      if (!isCurrent(token)) throw StateError('Verbindung wurde geändert');
      return action();
    });
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }
}
