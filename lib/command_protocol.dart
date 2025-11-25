class CommandProtocol {
  String createCommand(String action, String data) {
    final sanitizedAction = action.trim().toUpperCase();
    final sanitizedData = data.trim();
    if (sanitizedAction.isEmpty || sanitizedData.isEmpty) {
      throw ArgumentError('Action and data must not be empty');
    }
    return '$sanitizedAction:$sanitizedData';
  }
}

