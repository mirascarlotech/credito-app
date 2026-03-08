import 'package:credito_app/src/clients/chat_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final creditoChatProviderProvider = Provider<CreditoChatProvider>((ref) {
  return CreditoChatProvider(chatClient: ref.watch(chatClientProvider));
});

class CreditoChatProvider extends LlmProvider with ChangeNotifier {
  final ChatClient _chatClient;
  final List<ChatMessage> _history;

  String? _previousResponseId;

  CreditoChatProvider({required ChatClient chatClient, Iterable<ChatMessage>? history})
    : _chatClient = chatClient,
      _history = history?.toList() ?? [];

  @override
  Stream<String> generateStream(String prompt, {Iterable<Attachment> attachments = const []}) async* {
    final stream = _chatClient.sendMessageStream(prompt, previousResponseId: _previousResponseId);

    yield* stream
        .map((event) {
          // If event is a response.created, we update the previousResponseId so that the next message will be threaded correctly.
          _previousResponseId = event.asResponseCreated()?.response.id ?? _previousResponseId;
          // If event is a output.text.delta, we append the delta to the current message in the history so that the UI can reflect the streaming response.
          return event.asResponseOutputTextDelta()?.delta;
        })
        .where((text) => text != null)
        .cast<String>();
  }

  @override
  Stream<String> sendMessageStream(String prompt, {Iterable<Attachment> attachments = const []}) async* {
    final userMessage = ChatMessage.user(prompt, attachments);
    final llmMessage = ChatMessage.llm();
    _history.addAll([userMessage, llmMessage]);

    final stream = generateStream(prompt, attachments: attachments);

    yield* stream.map((text) {
      llmMessage.append(text);
      return text;
    });

    notifyListeners();
  }

  @override
  Iterable<ChatMessage> get history => _history;

  @override
  set history(Iterable<ChatMessage> history) {
    _history.clear();
    _history.addAll(history);
    notifyListeners();
  }

  /// Clears the chat history and resets the response ID for a new conversation
  void startNewChat() {
    _history.clear();
    _previousResponseId = null;
    notifyListeners();
  }
}
