/*
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/EnumAliaser.dart';
import 'package:todo_calendar_client/edit_widgets/TaskEditingPageWidget.dart';
import 'package:todo_calendar_client/models/requests/UserInfoRequestModel.dart';
import 'package:todo_calendar_client/models/responses/ChatMessagesResponse.dart';
import 'package:todo_calendar_client/models/responses/MessageInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/ShortChatInfoResponse.dart';
import 'dart:convert';
import 'package:todo_calendar_client/models/responses/additional_responces/GetResponse.dart';
import 'package:todo_calendar_client/shared_pref_cached_data.dart';
import 'package:todo_calendar_client/main_widgets/user_page.dart';
import 'package:todo_calendar_client/GlobalEndpoints.dart';
import 'package:todo_calendar_client/add_widgets/TaskPlaceholderWidget.dart';
import 'package:todo_calendar_client/models/responses/TaskInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithToken.dart';

class ChatMessagesListPageWidget extends StatefulWidget {

  final int chatId;

  ChatMessagesListPageWidget({required this.chatId});

  @override
  ChatMessagesListPageState createState() => ChatMessagesListPageState(chatId: chatId);
}

class ChatMessagesListPageState extends State<ChatMessagesListPageWidget> {

  final headers = {'Content-Type': 'application/json'};
  bool isColor = false;

  final EnumAliaser aliaser = new EnumAliaser();

  final int chatId;
  String chatName = 'Пустой чат';

  ChatMessagesListPageState({required this.chatId});

  List<MessageInfoResponse> messagesList = [
    MessageInfoResponse(
    messageId: 1,
    text: 'Пустой текст',
    sendTime: DateTime.now().toLocal().toString(),
    isEdited: false,
    writerId: 1,
    writerName: 'Tigeroff'
  )];


  Future<void> getChatMessagesInfo() async {

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();

      var model = new UserInfoRequestModel(userId: userId, token: token);
      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/chatting/get_chat_info';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentUri + currentPort + requestString);

      final body = jsonEncode(requestMap);

      try {
        final response = await http.post(url, headers: headers, body: body);

        var jsonData = jsonDecode(response.body);
        var responseContent = GetResponse.fromJson(jsonData);

        if (responseContent.result) {
          var userRequestedInfo = responseContent.requestedInfo.toString();

          print(userRequestedInfo);
          var data = jsonDecode(userRequestedInfo);

          var chatInfo = ChatMessagesResponse.fromJson(data);

         setState(() {
          chatName = chatInfo.caption;
         });

          var userMessages = data['messages'];

          var fetchedMessages =
          List<MessageInfoResponse>
              .from(userMessages.map(
                  (data) => MessageInfoResponse.fromJson(data)));

          setState(() {
            messagesList = fetchedMessages;
          });
        }
      }
      catch (e) {
        if (e is SocketException) {
          //treat SocketException
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Ошибка!'),
              content: Text('Проблема с соединением к серверу!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
        else if (e is TimeoutException) {
          //treat TimeoutException
          print("Timeout exception: ${e.toString()}");
        }
        else
          print("Unhandled exception: ${e.toString()}");
      }
    }
    else {
          setState(() {
            showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(
                    title: Text('Ошибка!'),
                    content:
                    Text(
                        'Произошла ошибка при получении'
                            ' полной информациио чате!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
            );
          });
        }
      }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Сообщения чата ' + chatName + ': '),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => UserPage()),);
            },
          ),
        ),
        body: messagesList.length == 0
        ? Column(
          children: [
            SizedBox(height: 16.0),
            Text(
              'Сообщений пока нет? Но вы можете отправить первое!',
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 26),
              textAlign: TextAlign.center)
          ],
        )
        : ListView.builder(
          itemCount: messagesList.length,
          itemBuilder: (context, index) {
            final data = messagesList[index];
            return Card(
              color: isColor ? Colors.cyan : Colors.greenAccent,
              elevation: 15,
              child: InkWell(
                onTap: () {
                  setState(() {
                    isColor = !isColor;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Название чата: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        utf8.decode(utf8.encode(data.caption)),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Имя получателя: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        utf8.decode(utf8.encode(data.receiverName)),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        child: Text('Зайти в чат'),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context)
                            => TaskEditingPageWidget(taskId: data.receiverId)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
*/