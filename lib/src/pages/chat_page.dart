import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_providers.dart';

class ChatPage extends ConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creditoChatProvider = ref.watch(creditoChatProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Start new chat',
            onPressed: () {
              creditoChatProvider.startNewChat();
            },
          ),
        ],
      ),
      body: LlmChatView(
        welcomeMessage: 'Hello! How can I assist you today?',
        enableAttachments: false,
        provider: creditoChatProvider,
      ),
    );
  }
}
