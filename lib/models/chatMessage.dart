import './userMate.dart';
import 'user.dart';

class ChatMessage {
  final UserMate userMate;
  final User sender;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.userMate,
    required this.sender,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'userMate': userMate,
        'sender': sender,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
      };

  // 從JSON格式轉換為ChatMessage
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        userMate: json['userMate'],
        sender: json['sender'],
        message: json['message'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}
