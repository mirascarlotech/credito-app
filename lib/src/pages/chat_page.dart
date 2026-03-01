import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatPage extends ConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: LlmChatView(
        welcomeMessage: 'Hello! How can I assist you today?',
        enableAttachments: false,
        provider: FirebaseProvider(
          // Use the Google AI endpoint
          model: FirebaseAI.googleAI().generativeModel(
            model: 'gemini-2.5-flash',
          ),
        ),
      ),
    );
  }
}