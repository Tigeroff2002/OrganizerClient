import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/content_widgets/single_content_widgets/SingleGroupPageWidget.dart';
import 'dart:convert';
import 'package:todo_calendar_client/models/requests/AddNewGroupModel.dart';
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

  final TextEditingController groupNameController = TextEditingController();

  GroupPlaceholderState(
      {
        required this.color,
        required this.text,
        required this.index
      });

  int createGroupId = -1;

  Future<void> addNewGroup(BuildContext context) async
  {
    String name = groupNameController.text;
    String groupType = selectedGroupType;

    var participants = [2, 3];

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();

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

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/groups/create';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentUri + currentPort + requestString);

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
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor : Colors.white,
                        shadowColor: Colors.cyan,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        minimumSize: Size(150, 50)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SingleGroupPageWidget(groupId: createGroupId)));
                    },
                    child: Text('Перейти на страницу новой группы с id = ' + createGroupId.toString()),
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

  @override
  Widget build(BuildContext context) {

    final groupTypes = ['None', 'Educational', 'Job'];

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
              TextField(
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
              SizedBox(height: 8.0),
              selectedGroupType == 'None'
                ? Text(
                   'Данная группа будет открытой, доступной для всех пользователей',
                    style: TextStyle(fontSize: 16, color: Colors.deepOrange))
                : Text(
                   'Доступно ограничение видимости группы для пользователей',
                   style: TextStyle(fontSize: 16, color: Colors.deepOrange)),
              SizedBox(height: 30.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor : Colors.white,
                    shadowColor: Colors.cyan,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    minimumSize: Size(150, 50)),
                onPressed: () async {
                  setState(() {
                    isNameValidated = !groupNameController.text.isEmpty;

                    if (isNameValidated){
                      addNewGroup(context);
                    }
                  });
                },
                child: Text('Создать новую группу'),
              ),
            ],
      ),
      )
    );
  }

  String selectedGroupType = "None";
}