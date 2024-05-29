import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/content_widgets/single_content_widgets/SingleGroupPageWidget.dart';
import 'package:todo_calendar_client/main_widgets/user_page.dart';
import 'dart:convert';
import 'package:todo_calendar_client/models/requests/AddNewGroupModel.dart';
import 'package:todo_calendar_client/models/requests/users_list_requests/AllUsersRequestModel.dart';
import 'package:todo_calendar_client/models/responses/ShortUserInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/UsersListResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/GetResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithId.dart';
import '../GlobalEndpoints.dart';
import '../models/responses/additional_responces/ResponseWithToken.dart';
import '../shared_pref_cached_data.dart';

class GroupPlaceholderWidget extends StatefulWidget{

  final Color color;
  final String text;
  final int index;

  GroupPlaceholderWidget({required this.color, required this.text, required this.index});

  @override
  GroupPlaceholderState createState(){
    return new GroupPlaceholderState(color: color, text: text, index: index);
  }
}

class GroupPlaceholderState extends State<GroupPlaceholderWidget> {
  final Color color;
  final String text;
  final int index;

  bool isNameValidated = true;

  bool isServerDataLoaded = false;

  final TextEditingController groupNameController = TextEditingController();

  GroupPlaceholderState(
      {
        required this.color,
        required this.text,
        required this.index
      });

  int createGroupId = -1;

  String currentHost = GlobalEndpoints().mobileUri;

  List<ShortUserInfoResponse> users = [];

  int currentUserId = 1;

  Future<void> addNewGroup(BuildContext context) async
  {
    String name = groupNameController.text;
    String groupType = selectedGroupType;

    //var participants = [2, 3];

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      setState(() {
        currentHost = cacheContent.currentHost;
        currentUserId = cacheContent.userId;
      });

      var userId = cacheContent.userId;
      var token = cacheContent.firebaseToken.toString();

      List<int> participants = [];

      for (int key in choosedIndexes.keys){
        var value = choosedIndexes[key];
        if (value != null){
          if (value){
            participants.add(key);
          }
        }
      }

      if (participants.isEmpty){
         showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Ошибка!'),
            content: Text('Вы не выбрали пользоватателей группы'),
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

      var model = new AddNewGroupModel(
          userId: (userId),
          token: token,
          groupName: name,
          groupType: groupType,
          participants: participants
      );

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var requestString = '/groups/create';

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
            createGroupId = responseContent.id;
          });

          if (responseContent.outInfo != null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SingleGroupPageWidget(groupId: createGroupId)));
                    },
                    child: Text('Перейти на страницу новой группы с id = ' + createGroupId.toString(),
                      style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
                  ),
                )
            );
          }
        }

        groupNameController.clear();
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка!'),
          content: Text('Создание новой группы не произошло!'),
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

    Future<void> getAllUsers(BuildContext context) async {
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

      var model = new AllUsersRequestModel(userId: userId, token: token);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var requestString = '/users/get_all_users';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentHost + currentPort + requestString);

      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode(requestMap);

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {

          var jsonData = jsonDecode(response.body);
          var responseContent = GetResponse.fromJson(jsonData);

          if (responseContent.result){

            var userRequestedInfo = responseContent.requestedInfo.toString();

            var data = jsonDecode(userRequestedInfo);
            var usersList = data['users'];

          var allUsers = List<ShortUserInfoResponse>.from(
            usersList.map((e) => ShortUserInfoResponse.fromJson(e)));

          setState(() {
            users = allUsers.where((element) => element.userId != currentUserId).toList();
            usersCount = users.length;

            var list = choosedIndexes.length == 0
             ? List<(int, bool)>.from(
                users.map((e) => (e.userId, false))).toList()
             : List<(int, bool)>.from(
                users.map((e) => 
                  choosedIndexes.containsKey(e.userId) 
                  && !choosedIndexes.values.where((isChoosed) => isChoosed).isEmpty
                    ? (e.userId, true)
                    : (e.userId, false))).toList();

            choosedIndexes = Map<int, bool>.fromIterable(list, key: (m) {
              var key = m as (int, bool);
              return key.$1;
            },
            value: (m){
              var value  = m as (int, bool);
              return value.$2;
            });

            isServerDataLoaded = true;
          });
          }
        }

        groupNameController.clear();
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка!'),
          content: Text('Создание новой группы не произошло!'),
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

  int usersCount = 0;
  Map<int, bool> choosedIndexes = {};

  @override
  Widget build(BuildContext context) {

    final groupTypes = ['None', 'Educational', 'Job'];

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Страничка создания новой группы',
            style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
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
            Text(
              text,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            SizedBox(height: 20.0),
              TextField(
                style: TextStyle(fontSize: 16, color: Colors.deepPurple),
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
              ),
              SizedBox(height: 20.0),
              Text(
                'Тип группы:',
                style: TextStyle(fontSize: 16, color: Colors.deepPurple),
              ),
              SizedBox(height: 8.0),
              DropdownButton(
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
                  }),
              SizedBox(height: 10.0),
              selectedGroupType == 'None'
                ? Text(
                   'Данная группа будет открытой, доступной для всех пользователей',
                    style: TextStyle(fontSize: 16, color: Colors.deepOrange))
                : Text(
                   'Доступно ограничение видимости группы для пользователей',
                   style: TextStyle(fontSize: 16, color: Colors.deepOrange)),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: (){
                  setState(() {
                    getAllUsers(context).then((_) => {
                    showDialog(
                      context: context,
                      builder: (context){
                        return Dialog(
                          elevation: 0,
                          child: Container(
                            height: 1000,
                            alignment: Alignment.center,
                            child: 
                            ListView.builder(
      shrinkWrap: true,
      itemCount: usersCount,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text('Gujarat, India'),
        );
      },
    ),
                            ));})
                    });});},
                 child: Text(
                  'Выбрать пользователей', 
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),)),
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isNameValidated = !groupNameController.text.isEmpty;

                    if (isNameValidated){
                      addNewGroup(context);
                    }
                  });
                },
                child: Text('Создать новую группу',
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
              ),
            ],
      ),
      )
    )));
  }

  String selectedGroupType = "None";
}