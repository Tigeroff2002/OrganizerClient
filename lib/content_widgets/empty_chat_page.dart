import 'package:flutter/material.dart';

class EmptyChatPage extends StatefulWidget{

  @override
  EmptyChatPageState createState() => EmptyChatPageState();
}

class EmptyChatPageState extends State<EmptyChatPage>{

  final headers = {'Content-Type': 'application/json'};
  bool isColor = false;

    @override
    void initState() {
      super.initState();
  }

    @override
    Widget build(BuildContext context) {
    return MaterialApp(
      theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Сообщения чата (отсутствуют): '),
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

    Future<void> addFirstChatMessage(BuildContext context) async {

      String snapshotType = selectedSnapshotType;
      String beginMoment = selectedBeginDateTime.toString();
      String endMoment = selectedEndDateTime.toString();

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();

      var model = new AddNewSnapshotModel(
          userId: (userId),
          token: token,
          snapshotType: snapshotType,
          beginMoment: beginMoment,
          endMoment: endMoment
      );

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/snapshots/perform_new';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentUri + currentPort + requestString);

      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode(requestMap);

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {

          var jsonData = jsonDecode(response.body);
          var responseContent = Response.fromJson(jsonData);

          if (responseContent.outInfo != null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(responseContent.outInfo.toString())
                )
            );
          }
        }

        snapshotTypeController.clear();
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка!'),
          content: Text('Создание нового снапшота не произошло!'),
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
  }
} var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/chatting/get_possible_direct_chat';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentUri + currentPort + requestString);

      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode(requestMap);

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {

          var jsonData = jsonDecode(response.body);
          var responseContent = ChatMessagesResponse.fromJson(jsonData);

          var chatId = responseContent.chatId;

          Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => 
                      ChatMessagesListPageWidget(chatId: chatId)),);

          return true;
        }

        return false;
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка!'),
          content: Text('Создание нового снапшота не произошло!'),
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

      return false;
    }

    return false;
  }
}