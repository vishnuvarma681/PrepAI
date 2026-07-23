enum ChatSender {
  user,
  assistant,
}

class ChatMessageEntity {
  final String text;
  final ChatSender sender;
  final DateTime timestamp;

  const ChatMessageEntity({
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}
