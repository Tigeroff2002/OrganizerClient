class ChatMessagesResponse {
  final int chatId;
  final String caption;
  final String createTime;
  final dynamic userHome;
  final dynamic userAway;
  final List<dynamic> messages;

  ChatMessagesResponse(
      {required this.chatId,
      required this.caption,
      required this.createTime,
      required this.userHome,
      required this.userAway,
      required this.messages});

  factory ChatMessagesResponse.fromJson(Map<String, dynamic> json) {
    return ChatMessagesResponse(
        chatId: json['chat_id'],
        caption: json['caption'],
        createTime: json['create_time'],
        userHome: json['user_home'],
        userAway: json['user_away'],
        messages: json['messages']);
  }
}
