import 'package:todo_calendar_client/models/responses/MessageInfoResponse.dart';

class MessageInfoWithChatResponse extends MessageInfoResponse {
  final int chatId;
  final String chatCaption;
  final int receiverId;
  final String receiverName;

  MessageInfoWithChatResponse(
      {required int messageId,
      required String text,
      required String sendTime,
      required bool isEdited,
      required int writerId,
      required String writerName,
      required this.chatId,
      required this.chatCaption,
      required this.receiverId,
      required this.receiverName})
      : super(
            messageId: messageId,
            text: text,
            sendTime: sendTime,
            isEdited: isEdited,
            writerId: writerId,
            writerName: writerName);

  factory MessageInfoWithChatResponse.fromJson(Map<String, dynamic> json) {
    return MessageInfoWithChatResponse(
        messageId: json['message_id'],
        text: json['text'],
        sendTime: json['send_time'],
        isEdited: json['is_edited'],
        writerId: json['writer_id'],
        writerName: json['writer_name'],
        chatId: json['chat_id'],
        chatCaption: json['caption'],
        receiverId: json['receiver_id'],
        receiverName: json['receiver_name']);
  }
}
