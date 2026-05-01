import 'dart:async';

enum AppEventType {
  chapterCreated,
  chapterSaved,
  chapterDeleted,
  chapterCompleted,
}

class AppEvent {
  final AppEventType type;
  final Map<String, dynamic> data;

  const AppEvent({required this.type, this.data = const {}});
}

class EventBus {
  final StreamController<AppEvent> _controller =
      StreamController<AppEvent>.broadcast();

  Stream<AppEvent> get stream => _controller.stream;

  void emit(AppEvent event) => _controller.add(event);

  void dispose() => _controller.close();
}
