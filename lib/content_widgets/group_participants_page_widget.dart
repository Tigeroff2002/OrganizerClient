import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/EnumAliaser.dart';
import 'package:todo_calendar_client/content_widgets/events_list_page.dart';
import 'package:todo_calendar_client/content_widgets/group_manager_page.dart';
import 'package:todo_calendar_client/content_widgets/single_content_widgets/SingleGroupPageWidget.dart';
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

class GroupParticipantsPageWidget extends StatefulWidget {

  final int groupId;

  GroupParticipantsPageWidget({required this.groupId});

  @override
  GroupParticipantsPageState createState() =>
      new GroupParticipantsPageState(groupId: groupId);
}

class GroupParticipantsPageState extends State<GroupParticipantsPageWidget> {

  final int groupId;
  int userId = -1;

  final bool isUserManager = false;

  @override
  void initState() {
    super.initState();
    getUsersFromGroupInfo();
  }

  GroupParticipantsPageState({required this.groupId});

  final headers = {'Content-Type': 'application/json'};
  bool isColor = false;

  String groupName = 'пустая группа';
  String groupType = 'пустой тип';

  final EnumAliaser aliaser = new EnumAliaser();

  List<ShortUserInfoResponse> usersList = [];

  bool isServerDataLoaded = false;

  Future<void> getUsersFromGroupInfo() async {

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    setState(() {
      isServerDataLoaded = false;
    });

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

          var data = jsonDecode(userRequestedInfo);

          var userParticipants = data['participants'];

          var fetchedGroupUsers =
          List<ShortUserInfoResponse>
              .from(userParticipants.map(
                  (data) => ShortUserInfoResponse.fromJson(data)));

          setState(() {
            usersList = fetchedGroupUsers;
            groupName = data['group_name'].toString();
            groupType = data['group_type'].toString();
            isServerDataLoaded = true;
          });
        }
      }
      catch (e) {
        if (e is TimeoutException) {
          //treat TimeoutException
          print("Timeout exception: ${e.toString()}");
        }
        else{
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
        print("Unhandled exception: ${e.toString()}");
        }
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

          setState(() {
            getUsersFromGroupInfo();
          });

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
        if (e is TimeoutException) {
          //treat TimeoutException
          print("Timeout exception: ${e.toString()}");
        }
        else{
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
        print("Unhandled exception: ${e.toString()}");
        }
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
      theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
      home: Scaffold(
        appBar: AppBar(
          title: 
          Text(
            'Список пользователей группы ' + groupName + ': ',
            style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SingleGroupPageWidget(groupId: groupId)),);
            },
          ),
        ),
        body: ListView.builder(
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
                              children: !isServerDataLoaded
                              ? [Center(
                                  child: SpinKitCircle(
                                size: 100,
                                color: Colors.deepPurple, 
                                duration: Durations.medium1,) )]
                              : [
                                Text(
                                  'Пользователь с именем: ',
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 16),),
                                Text(
                                  utf8.decode(utf8.encode(data.userName)),
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 16,),),
                                SizedBox(height: 12),
                                Text(
                                  'Электронная почта: ',
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 16,),),
                                Text(
                                  utf8.decode(utf8.encode(data.userEmail)),
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 16),),
                                SizedBox(height: 12),
                                ElevatedButton(
                                  child: Text('Посмотреть календарь пользователя',
                                    style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context)
                                        => userId != data.userId
                                          ? ParticipantCalendarPageWidget(
                                              groupId: groupId,
                                              participantId: data.userId,
                                              participantName: data.userName,)
                                          : EventsListPageWidget()),);
                                        },),
                                  SizedBox(height: 10),
                                  ElevatedButton(
                                    child: userId != data.userId
                                      ? Text('Исключить пользователя', 
                                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),)
                                      : Text('Выйти из группы', 
                                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
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
                ),              
            );
  }
}