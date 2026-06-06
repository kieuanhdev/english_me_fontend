import 'package:flutter/material.dart';

/// Một tin nhắn trong đoạn hội thoại luyện nói với AI.
class ChatMessage {
  const ChatMessage({required this.role, required this.content});

  /// 'user' (người học) hoặc 'assistant' (AI).
  final String role;
  final String content;

  bool get isUser => role == 'user';

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// Chủ đề hội thoại gợi ý sẵn trên màn chọn chủ đề.
class ConversationTopic {
  const ConversationTopic({
    required this.titleVi,
    required this.promptValue,
    required this.icon,
  });

  /// Nhãn hiển thị tiếng Việt.
  final String titleVi;

  /// Giá trị chủ đề (tiếng Anh) gửi cho AI.
  final String promptValue;
  final IconData icon;
}

/// Kết quả tổng kết & nhận xét cả đoạn hội thoại.
class ConversationSummary {
  const ConversationSummary({
    required this.overallScore,
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.vocabSuggestions,
    required this.encouragement,
  });

  final int overallScore;
  final String summary;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> vocabSuggestions;
  final String encouragement;

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    List<String> list(dynamic v) =>
        (v as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[];
    return ConversationSummary(
      overallScore: (json['overallScore'] as num?)?.round() ?? 0,
      summary: json['summary'] as String? ?? '',
      strengths: list(json['strengths']),
      improvements: list(json['improvements']),
      vocabSuggestions: list(json['vocabSuggestions']),
      encouragement: json['encouragement'] as String? ?? '',
    );
  }
}
