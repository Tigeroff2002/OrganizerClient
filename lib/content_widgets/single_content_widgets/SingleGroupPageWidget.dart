import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/EnumAliaser.dart';
import 'package:todo_calendar_client/content_widgets/events_list_page.dart';
import 'package:todo_calendar_client/content_widgets/group_manager_page.dart';
import 'package:todo_calendar_client/content_widgets/group_participants_page_widget.dart';
import 'package:todo_calendar_client/models/requests/EditExistingGroupModel.dart';
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

  bool isUserManager = false;

  @override
  void initState() {
    super.initState();
    getExistedGroup();
  }

  SingleGroupPageState({required this.groupId});

  GroupInfoResponse group = 
    GroupInfoResponse(groupId: 1, groupName: '1', groupType: '2', managerId: 1);

  final headers = {'Content-Type': 'application/json'};
  bool isColor = false;

  String groupName = 'пустая группа';
  String groupType = 'пустой тип';

  final EnumAliaser aliaser = new EnumAliaser();

  List<ShortUserInfoResponse> usersList = [];

  Future<void> getExistedGroup() async {

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

          var data = jsonDecode(userRequestedInfo);
          var userParticipants = data['participants'];

          var fetchedGroupUsers =
          List<ShortUserInfoResponse>
              .from(userParticipants.map(
                  (data) => ShortUserInfoResponse.fromJson(data)));

          setState(() {
            usersList = fetchedGroupUsers;

            group = GroupInfoResponse.fromJson(data);

            groupName = group.groupName;
            groupType = group.groupType;
            isUserManager = userId == group.managerId;

            groupNameController.text = groupName;
            selectedGroupType = groupType;
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
  Widget build(BuildContext context) {

    final groupTypes = ['None', 'Educational', 'Job'];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
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
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
          padding: EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isUserManager
                ? TextField(
                controller: groupNameController,
                decoration: InputDecoration(
                  labelText: 'Наименование группы:',
                    labelStyle: TextStyle(
                      fontSize: 16.0,
                        color: Colors.deepPurple
                    ),
                    errorText: !isNameValidated
                        ? 'Название группы не может быть пустым'
                        : null
                ),
              )
              : Text(
                 'Наименование группы: ' + groupNameController.text,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
              SizedBox(height: 16.0),
              isUserManager
              ? Text(
                'Тип группы:',
                style: TextStyle(fontSize: 16, color: Colors.deepPurple),
              )
              : Text(
                'Тип группы: ' + selectedGroupType,
                style: TextStyle(fontSize: 16, color: Colors.deepPurple),
              ),
              isUserManager
              ? SizedBox(height: 8.0)
              : SizedBox(height: 0.0),
              isUserManager
              ? DropdownButton(
                  value: selectedGroupType,
                  items: groupTypes.map((String type){
                    return DropdownMenuItem(
                        value: type,
                        child: Text(type));
                  }).toList(),
                  onChanged: (String? newType){
                    setState(() {
                      selectedGroupType = newType.toString();
                    });
                  })
              : SizedBox(height: 0.0),
              isUserManager
              ? SizedBox(height: 8.0)
              : SizedBox(height: 0.0),
              selectedGroupType == 'None'
                ? Text(
                   'Доступно ограничение видимости группы для пользователей',
                    style: TextStyle(fontSize: 16, color: Colors.deepOrange))
                : Text(
                   'Данная группа будет открытой, доступной для всех пользователей',
                   style: TextStyle(fontSize: 16, color: Colors.deepOrange)),
                  SizedBox(height: 16.0),
                    isUserManager
                      ? ElevatedButton(
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
                  SizedBox(height: 12.0),
                  ElevatedButton(
                        child: Text('Просмотреть список пользователей'),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context)
                            => GroupParticipantsPageWidget(groupId: groupId)),
                          );
                        },
                      ),
                  SizedBox(height: 12.0),
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor : Colors.white,
                  shadowColor: Colors.cyan,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  minimumSize: Size(250, 100),
                ),
                onPressed: () async {
                  setState(() {
                    isNameValidated = !groupNameController.text.isEmpty;

                    if (isNameValidated){
                      editCurrentGroup(context);
                    }
                  });
                },
                child: Text('Изменить параметры группы'),
              ),
            ],
            ),              
        )
        )
        )
        );
  }

  Future<void> editCurrentGroup(BuildContext context) async
  {
    String groupName = groupNameController.text;
    String groupType = selectedGroupType.toString();

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();

      var model = new EditExistingGroupModel(
          userId: userId,
          token: token,
          groupName: groupName,
          groupType: groupType,
          participants: [],
          groupId: groupId);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/groups/update_group_params';

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

        groupNameController.clear();

        setState(() {
          getExistedGroup();
        });
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
          content: Text('Изменение существующей задачи не удалось!'),
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

    final TextEditingController groupNameController = TextEditingController();
    bool isNameValidated = true;

    String selectedGroupType = "None";
}