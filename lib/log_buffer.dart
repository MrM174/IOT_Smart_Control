class LogBuffer {
  LogBuffer({this.capacity = 5});

  final int capacity;
  final List<String> _logs = <String>[];

  void add(String entry) {
    if (entry.trim().isEmpty) {
      return;
    }
    _logs.add(entry);
    if (_logs.length > capacity) {
      _logs.removeAt(0);
    }
  }

  List<String> getLogs() => List<String>.unmodifiable(_logs);
}

