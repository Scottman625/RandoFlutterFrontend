import 'user.dart';

class ChatRoom {
  final int id;
  final String other_side_image_url;
  final String other_side_name;
  final String last_message;
  int unread_nums;
  final DateTime last_message_time;
  final User other_side_user;
  final int other_side_age;
  final String other_side_career;
  String current_user_id;

  ChatRoom({
    required this.id,
    required this.other_side_image_url,
    required this.other_side_name,
    required this.last_message,
    required this.unread_nums,
    required this.last_message_time,
    required this.other_side_user,
    required this.other_side_age,
    required this.other_side_career,
    required this.current_user_id,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'other_side_image_url': other_side_image_url,
        'other_side_name': other_side_name,
        'last_message': last_message,
        'last_message_time': last_message_time.toIso8601String(),
        'unread_nums': unread_nums,
        'other_side_user': other_side_user.toJson(),
        'other_side_age': other_side_age,
        'other_side_career': other_side_career,
        'current_user_id': current_user_id,
      };

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      other_side_image_url: json['other_side_image_url'] ?? '',
      other_side_name:
          json['other_side_user']['name'] ?? json['other_side_name'],
      last_message: json['last_message'] ?? '',
      unread_nums: json['unread_nums'] ?? 0,
      last_message_time: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : DateTime.now(),
      other_side_user: User.fromJson(json['other_side_user']),
      other_side_age: json['other_side_user']['age'] ?? 18,
      other_side_career: json['other_side_user']['career'] ?? '',
      current_user_id: json['current_user_id'].toString(),
    );
  }
}

// class ChatroomUserShip {
//   final ChatRoom chatroom;
//   final User user;

//   ChatroomUserShip({required this.chatroom, required this.user});
// }

class ChatMessage {
  final String user_id;
  // final String other_side_image_url;
  final String other_side_phone;
  String? content; // 这个字段现在是可空的
  final DateTime create_at;
  final bool message_is_mine;
  final bool showMessageTime;
  String? image; // 这个字段现在是可空的

  ChatMessage({
    required this.user_id,
    // required this.other_side_image_url,
    required this.other_side_phone,
    this.content, // 这个字段现在是可空的
    required this.create_at,
    required this.message_is_mine,
    required this.showMessageTime,
    this.image, // 这个字段现在是可空的
  });

  Map<String, dynamic> toJson() => {
        'user_id': user_id,
        // 'other_side_image_url': other_side_image_url,
        'other_side_phone': other_side_phone,
        'content': content,
        'create_at': create_at.toIso8601String(),
        'message_is_mine': message_is_mine,
        'showMessageTime': showMessageTime,
      };

// 從JSON格式轉換為ChatMessage{}
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        user_id: json['sender'].toString(),
        // other_side_image_url: json['other_side_image_url'] ?? '',
        other_side_phone: json['other_side_phone'] ?? '',
        content: json['content'] ?? '',
        create_at: DateTime.parse(json['create_at']),
        message_is_mine: json['message_is_mine'] ?? true,
        showMessageTime: json['should_show_time'] ?? true,
        image: json['image'],
      );
}
