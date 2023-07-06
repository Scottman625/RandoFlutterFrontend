import 'user.dart';

class ChatRoom {
  final int id;
  final String other_side_image_url;
  final String other_side_name;
  final String last_message;
  final int unread_num;
  final DateTime update_at;
  final User other_side_user;
  final int other_side_age;
  final String other_side_career;

  ChatRoom({
    required this.id,
    required this.other_side_image_url,
    required this.other_side_name,
    required this.last_message,
    required this.unread_num,
    required this.update_at,
    required this.other_side_user,
    required this.other_side_age,
    required this.other_side_career,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      other_side_image_url: json['other_side_image_url'],
      other_side_name: json['other_side_name'],
      last_message: json['last_message'],
      unread_num: json['unread_num'],
      update_at: DateTime.parse(json['update_at']),
      other_side_user: User.fromJson(json['other_side_user']),
      other_side_age: json['other_side_age'],
      other_side_career: json['other_side_career'],
    );
  }
}

// class ChatroomUserShip {
//   final ChatRoom chatroom;
//   final User user;

//   ChatroomUserShip({required this.chatroom, required this.user});
// }

class ChatMessage {
  // final String userId;
  final String other_side_image_url;
  final String other_side_phone;
  final String message;
  final DateTime sentTime;
  final bool message_is_mine;
  final bool showMessageTime;

  ChatMessage({
    // required this.userId,
    required this.other_side_image_url,
    required this.other_side_phone,
    required this.message,
    required this.sentTime,
    required this.message_is_mine,
    required this.showMessageTime,
  });

  Map<String, dynamic> toJson() => {
        // 'userId': userId,
        'other_side_image_url': other_side_image_url,
        'other_side_phone': other_side_phone,
        'message': message,
        'sentTime': sentTime.toIso8601String(),
        'message_is_mine': message_is_mine,
        'showMessageTime': showMessageTime,
      };

// 從JSON格式轉換為ChatMessage{}
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        // userId: json['userId'],
        other_side_image_url: json['other_side_image_url'],
        other_side_phone: json['other_side_phone'],
        message: json['content'],
        sentTime: DateTime.parse(json['create_at']),
        message_is_mine: json['message_is_mine'],
        showMessageTime: json['should_show_time'],
      );
}
