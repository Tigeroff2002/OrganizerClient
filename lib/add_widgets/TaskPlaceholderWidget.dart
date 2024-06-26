import 'dart:async';
import 'dart:io';
import 'package:todo_calendar_client/add_widgets/GroupPlaceholderWidget.dart';
import 'package:todo_calendar_client/content_widgets/single_content_widgets/SingleTaskPageWidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/main_widgets/user_page.dart';
import 'dart:convert';
import 'package:todo_calendar_client/models/requests/AddNewTaskModel.dart';
import 'package:todo_calendar_client/models/requests/UserInfoRequestModel.dart';
import 'package:todo_calendar_client/models/requests/users_list_requests/AllGroupUsersRequestModel.dart';
import 'package:todo_calendar_client/models/responses/GroupInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/ShortUserInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithId.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/GetResponse.dart';
import '../GlobalEndpoints.dart';
import '../models/responses/additional_responces/ResponseWithToken.dart';
import '../shared_pref_cached_data.dart';

class TaskPlaceholderWidget extends StatefulWidget {
  final Color color;
  final String text;
  final int index;

  TaskPlaceholderWidget(
      {required this.color, required this.text, required this.index});

  @override
  TaskPlaceholderState createState() {
    return new TaskPlaceholderState(color: color, text: text, index: index);
  }
}

class TaskPlaceholderState extends State<TaskPlaceholderWidget> {
  final Color color;
  final String text;
  final int index;

  final TextEditingController taskCaptionController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();

  bool isCaptionValidated = true;
  bool isDescriptionValidated = true;

  TaskPlaceholderState(
      {required this.color, required this.text, required this.index});

  @override
  void initState() {
    setState(() {
      isServerDataLoaded = false;
    });

    getGroupUsers(context).then((_) {
      isServerDataLoaded = true;
    });
  }

  List<ShortUserInfoResponse> users = [];

  int createdTaskId = -1;

  int currentUserId = -1;

  int implementerId = -1;
  String implementerName = "";

  bool isServerDataLoaded = false;

  int currentGroupId = -1;
  String currentGroupName = "";

  String currentHost = GlobalEndpoints().mobileUri;

  Future<void> addNewTask(BuildContext context) async {
    String caption = taskCaptionController.text;
    String description = taskDescriptionController.text;
    String taskType = selectedTaskType.toString();
    String taskStatus = selectedTaskStatus.toString();

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      setState(() {
        currentHost = cacheContent.currentHost;
      });

      var userId = cacheContent.userId;
      var token = cacheContent.firebaseToken.toString();

      var model = new AddNewTaskModel(
          userId: (userId),
          token: token,
          caption: caption,
          description: description,
          taskType: taskType,
          taskStatus: taskStatus,
          implementerId: implementerId);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var requestString = '/tasks/create';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentHost + currentPort + requestString);

      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode(requestMap);

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          var responseContent = ResponseWithId.fromJson(jsonData);

          setState(() {
            createdTaskId = responseContent.id;
          });

          if (responseContent.outInfo != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SingleTaskPageWidget(taskId: createdTaskId)));
                },
                child: Text(
                  'Перейти на страницу новой задачи с id = ' +
                      createdTaskId.toString(),
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
              ),
            ));
          }
        }

        taskCaptionController.clear();
        taskDescriptionController.clear();
      } catch (e) {
        if (e is TimeoutException) {
          //treat TimeoutException
          print("Timeout exception: ${e.toString()}");
        } else {
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
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка!'),
          content: Text('Создание новой задачи не произошло!'),
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

  final headers = {'Content-Type': 'application/json'};

  List<GroupInfoResponse> groupsList = [];

    Future<void> getUserInfo() async {
    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    setState(() {
      isServerDataLoaded = false;
    });

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      setState(() {
        currentHost = cacheContent.currentHost;
      });

      setState(() {
        currentUserId = cacheContent.userId;
      });

      var token = cacheContent.firebaseToken.toString();

      var model = new UserInfoRequestModel(userId: currentUserId, token: token);
      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = currentHost;

      var requestString = '/users/get_info';

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
          var userGroups = data['user_groups'];

          var fetchedGroups = List<GroupInfoResponse>.from(
              userGroups.map((data) => GroupInfoResponse.fromJson(data)));

          setState(() {
            groupsList = fetchedGroups;
            isServerDataLoaded = true;
          });
        }
      } catch (e) {
        if (e is TimeoutException) {
          //treat TimeoutException
          print("Timeout exception: ${e.toString()}");
        } else {
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
    } else {
      setState(() {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Ошибка!'),
            content: Text('Произошла ошибка при получении'
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

  Future<void> getGroupUsers(BuildContext context) async {
    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    setState(() {
      isServerDataLoaded = false;
    });

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      setState(() {
        currentHost = cacheContent.currentHost;
      });

      var userId = cacheContent.userId;
      var token = cacheContent.firebaseToken.toString();

      getUserInfo().then((_){
      if (groupsList.isEmpty){
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Ошибка!'),
              content: Text('Вы должны состоять хотя бы в одной группе'),
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

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => GroupPlaceholderWidget(
              color: color,
              text: text,
              index: 2)),);
      }
      else {
        setState(() {
          currentGroupId = groupsList.first.groupId;
          currentGroupName = groupsList.first.groupName;          
        });
      }

      var model = 
        new AllGroupUsersRequestModel(
          userId: userId,
          token: token,
          groupId: currentGroupId);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var requestString = '/users/get_group_users';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentHost + currentPort + requestString);

      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode(requestMap);

      try {
        http.post(url, headers: headers, body: body).then((response){
        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          var responseContent = GetResponse.fromJson(jsonData);

          if (responseContent.result) {
            var userRequestedInfo = responseContent.requestedInfo.toString();

            var data = jsonDecode(userRequestedInfo);
            var usersList = data['users'];

            var allUsers = List<ShortUserInfoResponse>.from(
                usersList.map((e) => ShortUserInfoResponse.fromJson(e)));

            setState(() {
              users = allUsers;
              implementerId = currentUserId;
              isServerDataLoaded = true;
            });
          }
        }

          taskCaptionController.clear();
        });
      } catch (e) {
        if (e is TimeoutException) {
          //treat TimeoutException
          print("Timeout exception: ${e.toString()}");
        } else {
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
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка!'),
          content: Text('Создание новой задачи не произошло!'),
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

  @override
  Widget build(BuildContext context) {
    var taskTypes = ['None', 'AbstractGoal', 'MeetingPresense', 'JobComplete'];
    var taskStatuses = ['None', 'ToDo', 'InProgress', 'Review', 'Done'];

    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
        home: Scaffold(
            appBar: AppBar(
              title: Text(
                'Страничка создания новой задачи',
                style: TextStyle(fontSize: 16, color: Colors.deepPurple),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UserPage()),
                  );
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
                      Text(
                        text,
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple),
                      ),
                      SizedBox(height: 30.0),
                      SizedBox(height: 16.0),
                      TextField(
                        controller: taskCaptionController,
                        style:
                            TextStyle(fontSize: 16, color: Colors.deepPurple),
                        decoration: InputDecoration(
                            labelText: 'Наименование задачи: ',
                            labelStyle: TextStyle(
                                fontSize: 16, color: Colors.deepPurple),
                            errorText: !isCaptionValidated
                                ? 'Название задачи не может быть пустым'
                                : null),
                      ),
                      SizedBox(height: 12.0),
                      TextFormField(
                        controller: taskDescriptionController,
                        style:
                            TextStyle(fontSize: 16, color: Colors.deepPurple),
                        maxLines: null,
                        decoration: InputDecoration(
                            labelText: 'Описание задачи: ',
                            labelStyle: TextStyle(
                                fontSize: 16, color: Colors.deepPurple),
                            errorText: !isDescriptionValidated
                                ? 'Описание мероприятия не может быть пустым'
                                : null),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Тип задачи',
                        style:
                            TextStyle(fontSize: 16, color: Colors.deepPurple),
                      ),
                      SizedBox(height: 8.0),
                      DropdownButton(
                          value: selectedTaskType,
                          items: taskTypes.map((String type) {
                            return DropdownMenuItem(
                                value: type, child: Text(type));
                          }).toList(),
                          onChanged: (String? newType) {
                            setState(() {
                              selectedTaskType = newType.toString();
                            });
                          }),
                      SizedBox(height: 12.0),
                      Text(
                        'Статус задачи',
                        style:
                            TextStyle(fontSize: 16, color: Colors.deepPurple),
                      ),
                      SizedBox(height: 8.0),
                      DropdownButton(
                          value: selectedTaskStatus,
                          items: taskStatuses.map((String status) {
                            return DropdownMenuItem(
                                value: status, child: Text(status));
                          }).toList(),
                          onChanged: (String? newStatus) {
                            setState(() {
                              selectedTaskStatus = newStatus.toString();
                            });
                          }),
                      SizedBox(height: 6.0),
                      Text(
                        'Задача может быть выполнена участниками группы ' + currentGroupName,
                        style:
                            TextStyle(fontSize: 16, color: Colors.deepOrange),
                      ),
                      SizedBox(height: 16.0),
                      implementerId == currentUserId
                      ? Text(
                        'Задача по умолчанию назначается на вас',
                        style:
                            TextStyle(fontSize: 16, color: Colors.deepOrange),
                      )
                      : Text(
                        'Вы назначили задачу на другого исполнителя '
                         + implementerName,
                            style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
                      Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: users.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Row(
                              children: [
                                Text(users[index].userName,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.deepPurple)),
                                Checkbox(
                                    value: users[index].userId == implementerId,
                                    onChanged: (value) {
                                      setState(() {
                                        implementerId == users[index].userId;
                                        implementerName = 
                                          users.where((element) => element.userId == implementerId).first.userName;
                                      });
                                    })
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 0.0),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isCaptionValidated =
                                !taskCaptionController.text.isEmpty;
                            isDescriptionValidated =
                                !taskDescriptionController.text.isEmpty;

                            if (isCaptionValidated && isDescriptionValidated) {
                              addNewTask(context);
                            }
                          });
                        },
                        child: Text(
                          'Создать новую задачу',
                          style:
                              TextStyle(fontSize: 16, color: Colors.deepPurple),
                        ),
                      ),
                    ],
                  ),
                ))));
  }

  String selectedTaskType = 'None';
  String selectedTaskStatus = 'None';
}
