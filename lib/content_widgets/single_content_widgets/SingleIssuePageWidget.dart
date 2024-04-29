import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/content_widgets/issues_list_page.dart';
import 'dart:convert';
import 'package:todo_calendar_client/models/requests/AddNewTaskModel.dart';
import 'package:todo_calendar_client/models/requests/EditExistingIssueModel.dart';
import 'package:todo_calendar_client/models/requests/EditExistingTaskModel.dart';
import 'package:todo_calendar_client/models/requests/TaskInfoRequest.dart';
import 'package:todo_calendar_client/models/responses/IssueInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';
import 'package:todo_calendar_client/content_widgets/tasks_list_page.dart';
import '../../GlobalEndpoints.dart';
import '../../models/requests/IssueInfoRequest.dart';
import '../../models/responses/additional_responces/GetResponse.dart';
import '../../models/responses/additional_responces/ResponseWithToken.dart';
import '../../shared_pref_cached_data.dart';

class SingleIssuePageWidget extends StatefulWidget{

  final int issueId;

  SingleIssuePageWidget({ required this.issueId });

  @override
  SingleIssuePageState createState(){
    return new SingleIssuePageState(issueId: issueId);
  }
}

class SingleIssuePageState extends State<SingleIssuePageWidget> {

  final int issueId;

  SingleIssuePageState({ required this.issueId });

    @override
    void initState() {
      super.initState();
      getExistedIssue(context);
  }

  final TextEditingController issueTitleController = TextEditingController();
  final TextEditingController issueDescriptionController = TextEditingController();
  final TextEditingController issueLinkController = TextEditingController();

  bool isTitleValidated = true;
  bool isDescriptionValidated = true;
  bool isLinkValidated = true;

  IssueInfoResponse issue = IssueInfoResponse(
        issueId: 1,
        issueType: 'd',
        issueStatus: 'a',
        title: 'd',
        description: 'd',
        imgLink: 'd',
        createMoment: 'd'
    );

  Future<void> getExistedIssue(BuildContext context) async
  {
    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();

      var model = new IssueInfoRequest(userId: userId, token: token, issueId: issueId);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/issues/get_issue_info';

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
            issue = IssueInfoResponse.fromJson(data);

            issueTitleController.text = issue.title;
            issueDescriptionController.text = issue.description;
            issueLinkController.text = issue.imgLink;

            selectedIssueStatus = issue.issueStatus;
            selectedIssueType = issue.issueType;
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
          content: Text('Получение информации о текущем запросе не удалось!'),
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


  Future<void> editCurrentIssue(BuildContext context) async
  {
    String title = issueTitleController.text;
    String description = issueDescriptionController.text;
    String imgLink = issueLinkController.text;
    String issueType = selectedIssueType.toString();
    String issueStatus = selectedIssueStatus.toString();

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();

      var model = new EditExistingIssueModel(
          userId: userId,
          token: token,
          issueType: issueType,
          title: title,
          description: description,
          imgLink: imgLink,
          issueId: issueId,
          issueStatus: issueStatus);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/issues/update_issue_params';

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
          content: Text('Изменение существующего запроса не удалось!'),
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
    var issueStatuses = ['None', 'Reported', 'InProgress', 'Closed'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Страничка просмотра запроса для администрации'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => IssuesListPageWidget()),);
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
                'Изменение существующего запроса',
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
              Text(
                'Статус запроса',
                style: TextStyle(fontSize: 20, color: Colors.deepPurple),
              ),
              SizedBox(height: 4.0),
              DropdownButton(
                  value: selectedIssueStatus,
                  items: issueStatuses.map((String status){
                    return DropdownMenuItem(
                        value: status,
                        child: Text(status));
                  }).toList(),
                  onChanged: (String? newStatus){
                    setState(() {
                      selectedIssueStatus = newStatus.toString();
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
              SizedBox(height: 12.0),
              Image.network(utf8.decode(utf8.encode(issueLinkController.text)), scale: 0.01),
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
                    isTitleValidated = !issueTitleController.text.isEmpty;
                    isDescriptionValidated = !issueDescriptionController.text.isEmpty;
                    isLinkValidated = !issueLinkController.text.isEmpty;

                    if (isTitleValidated && isDescriptionValidated && isLinkValidated){
                      editCurrentIssue(context);
                    }
                  });
                },
                child: Text('Изменить текущий запрос'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String existedTitle = '';
  String existedDescription = '';
  String existedLink = '';

  String selectedIssueType = 'None';
  String existedIssueType = 'None';

  String selectedIssueStatus = 'None';
  String existedIssueStatus = 'None';
}