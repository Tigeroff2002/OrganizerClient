import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:todo_calendar_client/models/requests/AddNewSnapshotModel.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';
import '../GlobalEndpoints.dart';
import '../models/requests/AddNewIssueModel.dart';
import '../models/responses/additional_responces/ResponseWithToken.dart';
import '../shared_pref_cached_data.dart';

class IssuePlaceholderWidget extends StatefulWidget{

  final Color color;
  final String text;
  final int index;

  IssuePlaceholderWidget(
      {
        required this.color,
        required this.text,
        required this.index
      });

  @override
  IssuePlaceholderState createState(){
    return new IssuePlaceholderState(color: color, text: text, index: index);
  }
}

class IssuePlaceholderState extends State<IssuePlaceholderWidget> {

  final Color color;
  final String text;
  final int index;

  final TextEditingController issueTypeController = TextEditingController();
  final TextEditingController issueTitleController = TextEditingController();
  final TextEditingController issueDescriptionController = TextEditingController();
  final TextEditingController issueLinkController = TextEditingController();

  bool isTitleValidated = true;
  bool isDescriptionValidated = true;
  bool isLinkValidated = true;

  IssuePlaceholderState(
      {
        required this.color,
        required this.text,
        required this.index
      });

  Future<void> addNewIssue(BuildContext context) async
  {
    String issueType = selectedIssueType;
    String title = issueTypeController.text;
    String description = issueDescriptionController.text;
    String imgLink = issueLinkController.text;

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();

      var model = new AddNewIssueModel(
          userId: (userId),
          token: token,
          issueType: issueType,
          title: title,
          description: description,
          imgLink: imgLink
      );

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/snapshots/create_new';

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

        issueTypeController.clear();
        issueTitleController.clear();
        issueDescriptionController.clear();
        issueLinkController.clear();
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
          content: Text('Создание нового запроса не произошло!'),
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

    var issueTypes = ['None', 'BagIssue', 'ViolationIssue'];

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
                SizedBox(height: 30.0),
                SizedBox(height: 16.0),
                TextField(
                  controller: issueTitleController,
                  decoration: InputDecoration(
                      labelText: 'Заголовок запроса: ',
                      labelStyle: TextStyle(fontSize: 16, color: Colors.deepPurple),
                      errorText: !isTitleValidated
                          ? 'Заголовок запроса не может быть пустым'
                          : null
                  ),
                ),
                Text(
                  'Тип запроса',
                  style: TextStyle(fontSize: 20, color: Colors.deepPurple),
                ),
                SizedBox(height: 4.0),
                DropdownButton(
                    value: selectedIssueType,
                    items: issueTypes.map((String type){
                      return DropdownMenuItem(
                          value: type,
                          child: Text(type));
                    }).toList(),
                    onChanged: (String? newType){
                      setState(() {
                        selectedIssueType = newType.toString();
                      });
                    }),
                SizedBox(height: 12.0),
                TextFormField(
                  controller: issueDescriptionController,
                  maxLines: null,
                  decoration: InputDecoration(
                      labelText: 'Описание запроса: ',
                      labelStyle: TextStyle(fontSize: 16, color: Colors.deepPurple),
                      errorText: !isDescriptionValidated
                          ? 'Описание запроса не может быть пустым'
                          : null
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: issueLinkController,
                  maxLines: null,
                  decoration: InputDecoration(
                      labelText: 'Ссылка на скриншот (или страницу): ',
                      labelStyle: TextStyle(fontSize: 16, color: Colors.deepPurple),
                      errorText: !isLinkValidated
                          ? 'Ссылка не может быть пустой'
                          : null
                  ),
                ),
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
                      isTitleValidated = !issueTitleController.text.isEmpty;
                      isDescriptionValidated = !issueDescriptionController.text.isEmpty;
                      isLinkValidated = !issueLinkController.text.isEmpty;

                      if (isTitleValidated && isDescriptionValidated && isLinkValidated){
                        addNewIssue(context);
                      }
                    });
                  },
                  child: Text('Сделать новый запрос'),
                ),
              ]
          ),
        )
    );
  }

  String selectedIssueType = 'None';
}