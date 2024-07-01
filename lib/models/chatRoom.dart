class ChatRoom {
  final int id;
  final String otherSideImageUrl;
  final String otherSideName;
  final String lastMessage;
  int unreadNums;
  final DateTime lastMessageTime;
  final int otherSideAge;
  final String otherSideCareer;
  String currentUserId;
  String otherSideUserInfo;

  ChatRoom({
    required this.id,
    required this.otherSideImageUrl,
    required this.otherSideName,
    required this.lastMessage,
    required this.unreadNums,
    required this.lastMessageTime,
    required this.otherSideAge,
    required this.otherSideCareer,
    required this.currentUserId,
    required this.otherSideUserInfo,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'otherSideImageUrl': otherSideImageUrl,
        'otherSideName': otherSideName,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime.toIso8601String(),
        'unreadNums': unreadNums,
        'otherSideAge': otherSideAge,
        'otherSideCareer': otherSideCareer,
        'currentUserId': currentUserId,
        'otherSideUserInfo': otherSideUserInfo,
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
      otherSideAge: json['otherSideAge'] ?? json['otherSideUser']['age'],
      otherSideCareer: json['otherSideUser'] != null
          ? json['otherSideUser']['career']
          : json['otherSideCareer'],
      currentUserId: json['currentUser'] != null
          ? json['currentUser']['id'].toString()
          : json['currentUserId'].toString(),
      otherSideUserInfo:
          json['otherSideUserInfo'] != null ? json['otherSideUserInfo'] : '',
    );
  }
}
