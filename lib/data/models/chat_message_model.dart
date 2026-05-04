class ChatMessageModel {
  const ChatMessageModel({
    required this.role,
    required this.content,
    this.model,
  });

  final String role;
  final String content;
  final String? model;

  Map<String, String> toHistoryJson() {
    return {'role': role, 'content': content};
  }
}
