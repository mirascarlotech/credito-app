/// Response types for chat stream events
library;

class ChatResponse {
  final String id;

  ChatResponse({required this.id});

  static ChatResponse? fromJson(dynamic json) {
    final id = json['id'];
    if (id is String && id.isNotEmpty) {
      return ChatResponse(id: id);
    }
    return null;
  }
}

class ChatStreamEvent {
  final String type;

  ChatStreamEvent({required this.type});

  static ChatStreamEvent fromJson(dynamic json) {
    final subclassFromJsonBuilders = [
      ChatStreamEventResponseCreated.fromJson,
      ChatStreamEventResponseOutputTextDelta.fromJson,
    ];
    for (final builder in subclassFromJsonBuilders) {
      final event = builder(json);
      if (event != null) {
        return event;
      }
    }
    // Edge-case, return basic ChatStreamEvent with type only, should never happen
    return ChatStreamEvent(type: json['type'] ?? 'unknown');
  }

  ChatStreamEventResponseCreated? asResponseCreated() {
    if (this is ChatStreamEventResponseCreated) {
      return this as ChatStreamEventResponseCreated;
    }
    return null;
  }

  ChatStreamEventResponseOutputTextDelta? asResponseOutputTextDelta() {
    if (this is ChatStreamEventResponseOutputTextDelta) {
      return this as ChatStreamEventResponseOutputTextDelta;
    }
    return null;
  }
}

class ChatStreamEventResponseCreated extends ChatStreamEvent {
  static const String TYPE = 'response.created';

  final ChatResponse response;

  ChatStreamEventResponseCreated({required this.response}) : super(type: TYPE);

  static ChatStreamEventResponseCreated? fromJson(dynamic json) {
    if (json['type'] == TYPE) {
      final responseJson = json['response'];
      if (responseJson != null) {
        final response = ChatResponse.fromJson(responseJson);
        if (response != null) {
          return ChatStreamEventResponseCreated(response: response);
        }
      }
    }
    return null;
  }
}

class ChatStreamEventResponseOutputTextDelta extends ChatStreamEvent {
  static const String TYPE = 'response.output_text.delta';

  final String delta;

  ChatStreamEventResponseOutputTextDelta({required this.delta}) : super(type: TYPE);

  static ChatStreamEventResponseOutputTextDelta? fromJson(dynamic json) {
    if (json['type'] == TYPE) {
      final delta = json['delta'];
      if (delta is String && delta.isNotEmpty) {
        return ChatStreamEventResponseOutputTextDelta(delta: delta);
      }
    }
    return null;
  }
}
