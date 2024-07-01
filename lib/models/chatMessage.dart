// class ChatroomUserShip {
//   final ChatRoom chatroom;
//   final User user;

//   ChatroomUserShip({required this.chatroom, required this.user});
// }

class ChatMessage {
  // final String userId;
  // final String otherSideImageUrl;
  // final String otherSidePhone;
  String? content; // 这个字段现在是可空的
  final DateTime createAt;
  final bool messageIsMine;
  final bool showMessageTime;
  String? image; // 这个字段现在是可空的

  ChatMessage({
    // required this.userId,
    // required this.otherSideImageUrl,
    // required this.otherSidePhone,
    this.content, // 这个字段现在是可空的
    required this.createAt,
    required this.messageIsMine,
    required this.showMessageTime,
    this.image, // 这个字段现在是可空的
  });

  Map<String, dynamic> toJson() => {
        // 'userId': userId,
        // 'otherSideImageUrl': otherSideImageUrl,
        // 'otherSidePhone': otherSidePhone,
        'content': content,
        'createAt': createAt.toIso8601String(),
        'messageIsMine': messageIsMine,
        'showMessageTime': showMessageTime,
        'imageUrl': image,
      };

// 從JSON格式轉換為ChatMessage{}
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        // userId: json['chatroomMessage']['sender']['id'].toString(),
        // otherSidePhone: json['otherSidePhone'] ?? '',
        content: json['content'] != null ? json['content'] : '',
        createAt: json['createAt'] != null
            ? DateTime.parse(json['createAt'])
            : DateTime.parse(json['createAt']),
        messageIsMine: json['messageIsMine'] ?? true,
        showMessageTime: json['shouldShowTime'] ?? true,
        image: json['imageUrl'] != null ? json['imageUrl'] : '',
      );
}
