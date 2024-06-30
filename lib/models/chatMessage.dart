import 'user.dart';

class ChatRoom {
  final int id;
  final String otherSideImageUrl;
  final String otherSideName;
  final String lastMessage;
  int unreadNums;
  final DateTime lastMessageTime;
  final User otherSideUser;
  final int otherSideAge;
  final String otherSideCareer;
  String currentUserId;

  ChatRoom({
    required this.id,
    required this.otherSideImageUrl,
    required this.otherSideName,
    required this.lastMessage,
    required this.unreadNums,
    required this.lastMessageTime,
    required this.otherSideUser,
    required this.otherSideAge,
    required this.otherSideCareer,
    required this.currentUserId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'otherSideImageUrl': otherSideImageUrl,
        'otherSideName': otherSideName,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime.toIso8601String(),
        'unreadNums': unreadNums,
        'otherSideUser': otherSideUser.toJson(),
        'otherSideAge': otherSideAge,
        'otherSideCareer': otherSideCareer,
        'currentUserId': currentUserId,
      };

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
        id: json['id'] ?? json['chatroomId'],
        otherSideImageUrl: json['otherSideImageUrl'] != null
            ? json['otherSideImageUrl']
            : json['otherSideImageUrl'],
        otherSideName: json['otherSideName'] != null
            ? json['otherSideName']
            : json['otherSideName'],
        lastMessage: json['lastMessage'] ?? '',
        unreadNums: json['unreadNums'] ?? 0,
        lastMessageTime: json['lastMessageTime'] != null
            ? DateTime.parse(json['lastMessageTime'])
            : DateTime.now(),
        otherSideUser: json['otherSideChatRoomUser'] != null
            ? User.fromJson(json['otherSideChatRoomUser'])
            : User.fromJson(json['otherSideUser']),
        otherSideAge: json['otherSideAge'] ?? json['otherSideUser']['age'],
        otherSideCareer: json['otherSideUser'] != null
            ? json['otherSideUser']['career']
            : json['otherSideCareer'],
        currentUserId: json['currentUser'] != null
            ? json['currentUser']['id'].toString()
            : json['currentUserId'].toString());
  }
}

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
