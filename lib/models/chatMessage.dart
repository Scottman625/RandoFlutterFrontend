import 'user.dart';

class ChatRoom {
  final int id;
  final String other_side_image_url;
  final String other_side_name;
  final String last_message;
  final int unread_num;
  final DateTime last_message_time;
  final User other_side_user;
  final int other_side_age;
  final String other_side_career;
  final int current_user_id;

  ChatRoom({
    required this.id,
    required this.other_side_image_url,
    required this.other_side_name,
    required this.last_message,
    required this.unread_num,
    required this.last_message_time,
    required this.other_side_user,
    required this.other_side_age,
    required this.other_side_career,
    required this.current_user_id,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      other_side_image_url:
          json['other_side_user']['imageUrl'] ?? json['other_side_image_url'],
      other_side_name:
          json['other_side_user']['name'] ?? json['other_side_user_name'],
      last_message: json['last_message'] ?? '',
      unread_num: json['unread_num'] ?? 0,
      last_message_time: DateTime.parse(json['last_message_time']),
      other_side_user: User.fromJson(json['other_side_user']),
      other_side_age: json['other_side_user']['age'] ?? 18,
      other_side_career: json['other_side_user']['career'] ?? '',
      current_user_id: json['current_user']['id'] ?? '',
    );
  }
}

// class ChatroomUserShip {
//   final ChatRoom chatroom;
//   final User user;

//   ChatroomUserShip({required this.chatroom, required this.user});
// }

class ChatMessage {
  final int user_id;
  final String other_side_image_url;
  final String other_side_phone;
  final String message;
  final DateTime sendTime;
  final bool message_is_mine;
  final bool showMessageTime;

  ChatMessage({
    required this.user_id,
    required this.other_side_image_url,
    required this.other_side_phone,
    required this.message,
    required this.sendTime,
    required this.message_is_mine,
    required this.showMessageTime,
  });

  Map<String, dynamic> toJson() => {
        'user_id': user_id,
        'other_side_image_url': other_side_image_url,
        'other_side_phone': other_side_phone,
        'message': message,
        'sentTime': sendTime.toIso8601String(),
        'message_is_mine': message_is_mine,
        'showMessageTime': showMessageTime,
      };

// 從JSON格式轉換為ChatMessage{}
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        user_id: json['user'] ?? '',
        other_side_image_url: json['other_side_image_url'] ?? '',
        other_side_phone: json['other_side_phone'] ?? '',
        message: json['content'] ?? '',
        sendTime: DateTime.parse(json['create_at']),
        message_is_mine: json['message_is_mine'] ?? true,
        showMessageTime: json['should_show_time'] ?? true,
      );
}
