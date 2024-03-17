class MessageInfoResponse {

  final int messageId;
  final String text;
  final String sendTime;
  final bool isEdited;
  final int writerId;
  final String writerName;

  MessageInfoResponse({
    required this.messageId,
    required this.text,
    required this.sendTime,
    required this.isEdited,
    required this.writerId,
    required this.writerName
  });

  factory MessageInfoResponse.fromJson(Map<String, dynamic> json){
    return MessageInfoResponse(
      messageId: json['message_id'],
      text: json['text'],
      sendTime: json['send_time'],
      isEdited: json['is_edited'],
      writerId: json['writer_id'],
      writerName: json['writer_name']);
  }
}