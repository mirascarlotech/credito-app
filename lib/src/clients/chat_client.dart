import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../config/app_config.dart';
import '../models/chat_models.dart';

final chatClientProvider = Provider<ChatClient>((ref) {
  return ChatClient(chatEndpoint: AppConfig.chatApiEndpoint);
});

class ChatClient {
  static final _logger = Logger('ChatClient');

  final Dio _dio = Dio();
  final String _chatEndpoint;

  ChatClient({required String chatEndpoint}) : _chatEndpoint = chatEndpoint {
    _logger.info('ChatClient initialized with endpoint: $_chatEndpoint');
  }

  Stream<ChatStreamEvent> sendMessageStream(String prompt, {String? previousResponseId}) async* {
    final response = await _dio.post(
      _chatEndpoint,
      data: {'input': prompt, 'previousResponseId': previousResponseId, 'stream': true},
      options: Options(responseType: ResponseType.stream, headers: {'Accept': 'text/event-stream'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to connect: ${response.statusCode}');
    }

    final stream = response.data.stream;
    await for (final chunk in stream) {
      final lines = utf8.decode(chunk).split('\n');

      for (final line in lines) {
        if (!line.startsWith('data:')) {
          continue;
        }

        final rawData = line.substring('data:'.length).trim();
        if (rawData.isEmpty || rawData == '[DONE]') {
          continue;
        }

        try {
          final json = jsonDecode(rawData);
          yield ChatStreamEvent.fromJson(json);
        } catch (e, stackTrace) {
          _logger.warning('Failed to parse chat stream event', e, stackTrace);
        }
      }
    }
  }
}
