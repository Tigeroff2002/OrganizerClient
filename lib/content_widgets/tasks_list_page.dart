import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/EnumAliaser.dart';
import 'package:todo_calendar_client/content_widgets/single_content_widgets/SingleTaskPageWidget.dart';
import 'package:todo_calendar_client/content_widgets/user_info_map.dart';
import 'package:todo_calendar_client/models/requests/UserInfoRequestModel.dart';
import 'dart:convert';
import 'package:todo_calendar_client/models/responses/additional_responces/GetResponse.dart';
import 'package:todo_calendar_client/shared_pref_cached_data.dart';
import 'package:todo_calendar_client/main_widgets/user_page.dart';
import 'package:todo_calendar_client/GlobalEndpoints.dart';
import 'package:todo_calendar_client/add_widgets/TaskPlaceholderWidget.dart';
import 'package:todo_calendar_client/models/responses/TaskInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithToken.dart';

class TasksListPageWidget extends StatefulWidget {
  const TasksListPageWidget({super.key});


  @override
  TasksListPageState createState() => TasksListPageState();
}

class TasksListPageState extends State<TasksListPageWidget> {

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  bool isServerDataLoaded = false;

  final headers = {'Content-Type': 'application/json'};
  bool isColor = false;

  final EnumAliaser aliaser = new EnumAliaser();

  var emptyTask = new TaskInfoResponse(
      taskId: 1,
      caption: 'caption',
      description: 'description',
      taskType: 'taskType',
      taskStatus: 'taskStatus');

  
  List<TaskInfoResponse> tasksList = [
    TaskInfoResponse(
        taskId: 1,
        caption: 'caption',
        description: 'description',
        taskType: 'taskType',
        taskStatus: 'taskStatus')];


  Future<void> getUserInfo() async {
    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    setState(() {
      isServerDataLoaded = false;
    });

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
          var userTasks = data['user_tasks'];

          var fetchedTasks =
          List<TaskInfoResponse>
              .from(userTasks.map(
                  (data) => TaskInfoResponse.fromJson(data)));

          setState(() {
            tasksList = fetchedTasks;
            isServerDataLoaded = true;
          });
        }
      }
      catch (e) {
        if (e is TimeoutException) {
          //treat TimeoutException
          print("Timeout exception: ${e.toString()}");
        }
        else {
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
              builder: (context) =>
                  AlertDialog(
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Список созданных задач',
            style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => UserInfoMapPage()),);
            },
          ),
        ),
        body: tasksList.length == 0
        ? Column(
          children: !isServerDataLoaded
          ? [Center(
                      child: SpinKitCircle(
                        size: 100,
                        color: Colors.deepPurple, 
                        duration: Durations.medium1,) )]
          : [
            SizedBox(height: 16.0),
            Text(
              'Вы не брали ни одной задачи на реализацию',
              style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
              textAlign: TextAlign.center),
            SizedBox(height: 16.0),
            ElevatedButton(
                child: Text('Создать новую задачу',
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context)
                      => TaskPlaceholderWidget(
                          color: Colors.greenAccent, text: 'Составление новой задачи', index: 2))
                  );
                })
          ],
        )
        : ListView.builder(
          itemCount: tasksList.length,
          itemBuilder: (context, index) {
            final data = tasksList[index];
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
                    children: 
                  !isServerDataLoaded
                  ? [Center(
                      child: SpinKitCircle(
                        size: 100,
                        color: Colors.deepPurple, 
                        duration: Durations.medium1,) )]
                  : [
                      Text(
                        'Название задачи: ',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      Text(
                        utf8.decode(utf8.encode(data.caption)),
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Описание задачи: ',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      Text(
                        utf8.decode(utf8.encode(data.description)),
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Тип задачи: ',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      Text(
                        aliaser.GetAlias(
                            aliaser.getTaskTypeEnumValue(data.taskType)),
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Текущий статус задачи: ',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      Text(
                        aliaser.GetAlias(
                            aliaser.getTaskStatusEnumValue(data.taskStatus)),
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        child: Text('Просмотреть задачу',
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context)
                            => SingleTaskPageWidget(taskId: data.taskId)),
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