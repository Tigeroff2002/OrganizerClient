import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:todo_calendar_client/models/requests/AddNewTaskModel.dart';
import 'package:todo_calendar_client/models/requests/EditExistingTaskModel.dart';
import 'package:todo_calendar_client/models/requests/TaskInfoRequest.dart';
import 'package:todo_calendar_client/models/responses/TaskInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';
import 'package:todo_calendar_client/content_widgets/tasks_list_page.dart';
import '../../GlobalEndpoints.dart';
import '../../models/responses/additional_responces/GetResponse.dart';
import '../../models/responses/additional_responces/ResponseWithToken.dart';
import '../../shared_pref_cached_data.dart';

class SingleTaskPageWidget extends StatefulWidget{

  final int taskId;

  SingleTaskPageWidget({required this.taskId});

  @override
  SingleTaskPageState createState(){
    return new SingleTaskPageState(taskId: taskId);
  }
}

class SingleTaskPageState extends State<SingleTaskPageWidget> {

  final int taskId;

  SingleTaskPageState({required this.taskId});

    @override
    void initState() {
      super.initState();
      getExistedTask(context);
  }

  final TextEditingController taskCaptionController = TextEditingController();
  final TextEditingController taskDescriptionController = TextEditingController();

  bool isCaptionValidated = true;
  bool isDescriptionValidated = true;

  TaskInfoResponse task = new TaskInfoResponse(
        taskId: 1,
        caption: 'caption',
        description: 'description',
        taskType: 'taskType',
        taskStatus: 'taskStatus');

  Future<void> getExistedTask(BuildContext context) async
  {
    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();

      var model = new TaskInfoRequest(userId: userId, token: token, taskId: taskId);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/tasks/get_task_info';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentUri + currentPort + requestString);

      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode(requestMap);

      try {
        final response = await http.post(url, headers: headers, body: body);

        var jsonData = jsonDecode(response.body);
        var responseContent = GetResponse.fromJson(jsonData);

        if (responseContent.result) {
            var userRequestedInfo = responseContent.requestedInfo.toString();

            var data = jsonDecode(userRequestedInfo);

            setState(() {
              task = TaskInfoResponse.fromJson(data);
              
              existedCaption = task.caption;
              existedDescription = task.description;
              taskCaptionController.text = existedCaption;
              taskDescriptionController.text = existedDescription;
              selectedTaskStatus = task.taskStatus;
              selectedTaskType = task.taskType;
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка!'),
          content: Text('Получение инфы о задаче не удалось!'),
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


  Future<void> editCurrentTask(BuildContext context) async
  {
    String caption = taskCaptionController.text;
    String description = taskDescriptionController.text;
    String taskType = selectedTaskType.toString();
    String taskStatus = selectedTaskStatus.toString();

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();

      var implementerId = 3;

      var model = new EditExistingTaskModel(
          userId: userId,
          token: token,
          caption: caption,
          description: description,
          taskType: taskType,
          taskStatus: taskStatus,
          implementerId: implementerId,
          taskId: taskId);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/tasks/update_task_params';

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

        taskCaptionController.clear();
        taskDescriptionController.clear();
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

  @override
  Widget build(BuildContext context) {

    var taskTypes = ['None', 'AbstractGoal', 'MeetingPresense', 'JobComplete'];
    var taskStatuses = ['None', 'ToDo', 'InProgress', 'Review', 'Done'];

    return Scaffold(
        appBar: AppBar(
          title: Text('Страничка просмотра задачи'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => TasksListPageWidget()),);
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
                'Информация о задаче',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30.0),
              SizedBox(height: 16.0),
              TextField(
                controller: taskCaptionController,
                decoration: InputDecoration(
                    labelText: 'Наименование задачи: ',
                    labelStyle: TextStyle(
                        fontSize: 16.0,
                        color: Colors.deepPurple
                    ),
                    errorText: !isCaptionValidated
                        ? 'Название задачи не может быть пустым'
                        : null
                ),
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: taskDescriptionController,
                maxLines: null,
                decoration: InputDecoration(
                    labelText: 'Описание задачи: ',
                    labelStyle: TextStyle(
                        fontSize: 16.0,
                        color: Colors.deepPurple
                    ),
                    errorText: !isDescriptionValidated
                        ? 'Описание мероприятия не может быть пустым'
                        : null
                ),
              ),
              SizedBox(height: 12.0),
              Text(
                'Тип задачи',
                style: TextStyle(fontSize: 16, color: Colors.deepPurple),
              ),
              SizedBox(height: 4.0),
              DropdownButton(
                  value: selectedTaskType,
                  items: taskTypes.map((String type){
                    return DropdownMenuItem(
                        value: type,
                        child: Text(type));
                  }).toList(),
                  onChanged: (String? newType){
                    setState(() {
                      selectedTaskType = newType.toString();
                    });
                  }),
              SizedBox(height: 12.0),
              Text(
                'Статус задачи',
                style: TextStyle(fontSize: 16, color : Colors.deepPurple),
              ),
              SizedBox(height: 4.0),
              DropdownButton(
                  value: selectedTaskStatus,
                  items: taskStatuses.map((String status){
                    return DropdownMenuItem(
                        value: status,
                        child: Text(status));
                  }).toList(),
                  onChanged: (String? newStatus){
                    setState(() {
                      selectedTaskStatus = newStatus.toString();
                    });
                  }),
              SizedBox(height: 30.0),
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
                    isCaptionValidated = !taskCaptionController.text.isEmpty;
                    isDescriptionValidated = !taskDescriptionController.text.isEmpty;

                    if (isCaptionValidated && isDescriptionValidated){
                      editCurrentTask(context);
                    }
                  });
                },
                child: Text('Изменить текущую задачу'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String selectedTaskType = 'None';
  String selectedTaskStatus = 'None';

  String existedCaption = '';
  String existedDescription = '';
  String existedTaskType = 'None';
  String existedTaskStatus = 'None';
}