import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/EnumAliaser.dart';
import 'package:todo_calendar_client/content_widgets/events_list_page.dart';
import 'package:todo_calendar_client/content_widgets/group_manager_page.dart';
import 'package:todo_calendar_client/models/requests/GroupDeleteParticipantRequest.dart';
import 'package:todo_calendar_client/models/requests/GroupInfoRequest.dart';
import 'package:todo_calendar_client/models/requests/UserInfoRequestModel.dart';
import 'dart:convert';
import 'package:todo_calendar_client/models/responses/GroupInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/ShortUserInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/GetResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/GroupRequestedInfo.dart';
import 'package:todo_calendar_client/content_widgets/participant_calendar_page.dart';
import 'package:todo_calendar_client/shared_pref_cached_data.dart';
import 'package:todo_calendar_client/main_widgets/user_page.dart';
import 'package:todo_calendar_client/GlobalEndpoints.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/GroupGetResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithToken.dart';

class SingleGroupPageWidget extends StatefulWidget {

  final int groupId;

  SingleGroupPageWidget({required this.groupId});

  @override
  SingleGroupPageState createState() =>
      new SingleGroupPageState(groupId: groupId);
}

class SingleGroupPageState extends State<SingleGroupPageWidget> {

  final int groupId;
  int userId = -1;

  final bool isUserManager = false;

  @override
  void initState() {
    super.initState();
    getUsersFromGroupInfo();
  }

  SingleGroupPageState({required this.groupId});

  final headers = {'Content-Type': 'application/json'};
  bool isColor = false;

  String groupName = 'пустая группа';
  String groupType = 'пустой тип';

  final EnumAliaser aliaser = new EnumAliaser();

  List<ShortUserInfoResponse> usersList = [];

  Future<void> getUsersFromGroupInfo() async {

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null){
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      userId = cacheContent.userId;
      var token = cacheContent.token.toString();

      var model = new GroupInfoRequest(userId: userId, token: token, groupId: groupId);
      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/groups/get_group_info';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentUri + currentPort + requestString);

      final body = jsonEncode(requestMap);

      try {
        final response = await http.post(url, headers: headers, body: body);

        var jsonData = jsonDecode(response.body);
        var responseContent = GetResponse.fromJson(jsonData);

        if (responseContent.result) {
          var userRequestedInfo = responseContent.requestedInfo.toString();
          
          var rawBeginIndex = userRequestedInfo.indexOf('"participants"');
          var rawEndIndex = userRequestedInfo.indexOf(']}') + 2;

          var string = '{' + userRequestedInfo.substring(rawBeginIndex, rawEndIndex);
          print(string);

          var contentData = jsonDecode(string);
          print(contentData);

          var userParticipants = contentData['participants'];

          var data = jsonDecode(userRequestedInfo);

          var fetchedGroupUsers =
          List<ShortUserInfoResponse>
              .from(userParticipants.map(
                  (data) => ShortUserInfoResponse.fromJson(data)));

          setState(() {
            usersList = fetchedGroupUsers;
            groupName = data['group_name'].toString();
            groupType = data['group_type'].toString();
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
          builder: (context) => AlertDialog(
            title: Text('Ошибка!'),
            content:
            Text(
                'Произошла ошибка при получении'
                    ' полной информации о пользователе!'),
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

  Future<void> deleteUserFromGroup(int deletionUserId) async {

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null){
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();

      var model = new GroupDeleteParticipantRequest(
          userId: userId,
          token: token,
          groupId: groupId,
          participantId: deletionUserId);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/groups/delete_participant';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentUri + currentPort + requestString);

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
      }
      catch (e) {
        if (e is SocketException) {
          //treat SocketException
          print("Socket exception: ${e.toString()}");
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
          builder: (context) => AlertDialog(
            title: Text('Ошибка!'),
            content:
            Text(
                'Произошла ошибка при получении'
                    ' полной информации о пользователе!'),
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
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: 
          Text(
            'Информация о группе ' + groupName + ': ',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 16.0,
              fontWeight: FontWeight.bold)),
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
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(6.0),
            child: SingleChildScrollView(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text(
                      'Тип группы: ',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Text(aliaser.GetAlias(
                      aliaser.getUserRoleEnumValue(groupType)),
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                        )
                    ),
                    SizedBox(height: 16.0),
                    isUserManager
                      ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor : Colors.white,
                        shadowColor: Colors.greenAccent,
                        elevation: 3,
                        minimumSize: Size(200, 60),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupManagerPageWidget(groupId: groupId)),);
                      },
                      child: Text('Функционал менеджера'),)
                      : Text(
                        'Вам недоступен функционал системного менеджера',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold
                        ),
                    ),
                    ListView.builder(
                      itemCount: usersList.length,
                      itemBuilder: (context, index) {
                      final data = usersList[index];
                      return Card(
                        color: userId != data.userId
                          ? Colors.cyan
                          : Colors.red,
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
                                  'Пользователь с именем: ',
                                  style: TextStyle(
                                    color: Colors.white,),),
                                Text(
                                  utf8.decode(utf8.encode(data.userName)),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,),),
                                SizedBox(height: 12),
                                Text(
                                  'Электронная почта: ',
                                  style: TextStyle(
                                    color: Colors.white,),),
                                Text(
                                  utf8.decode(utf8.encode(data.userEmail)),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,),),
                                SizedBox(height: 12),
                                ElevatedButton(
                                  child: Text('Посмотреть календарь пользователя'),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context)
                                        => userId != data.userId
                                          ? ParticipantCalendarPageWidget(
                                              groupId: groupId,
                                              participantId: data.userId)
                                          : EventsListPageWidget()),);
                                        },),
                                  SizedBox(height: 10),
                                  ElevatedButton(
                                    child: userId != data.userId
                                      ? Text('Исключить пользователя')
                                      : Text('Выйти из группы'),
                                    onPressed: () {
                                      setState(() {
                                        deleteUserFromGroup(data.userId).then((value) => {
                                          usersList.removeWhere((element) => element.userId == data.userId)
                                        });
                                    });
                                  },),
                                  SizedBox(height: 10)
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),            
                  ],
                ),              
            ),
          ),)
      ),
    );
  }
}