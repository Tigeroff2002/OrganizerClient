import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/EnumAliaser.dart';
import 'package:todo_calendar_client/content_widgets/single_content_widgets/SingleIssuePageWidget.dart';
import 'package:todo_calendar_client/main_widgets/system_admin_page.dart';
import 'package:todo_calendar_client/models/requests/UserInfoRequestModel.dart';
import 'package:todo_calendar_client/models/responses/FullIssueInfoResponse.dart';
import 'dart:convert';
import 'package:todo_calendar_client/models/responses/additional_responces/GetResponse.dart';
import 'package:todo_calendar_client/shared_pref_cached_data.dart';
import 'package:todo_calendar_client/main_widgets/user_page.dart';
import 'package:todo_calendar_client/GlobalEndpoints.dart';
import 'package:todo_calendar_client/add_widgets/AddPersonalSnapshotWidget.dart';
import 'package:todo_calendar_client/models/responses/IssueInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/PersonalSnapshotInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithToken.dart';

class SystemIssuesListPageWidget extends StatefulWidget {
  const SystemIssuesListPageWidget({super.key});


  @override
  SystemIssuesListPageState createState() => SystemIssuesListPageState();
}

class SystemIssuesListPageState extends State<SystemIssuesListPageWidget> {

  @override
  void initState() {
    super.initState();
    getSystemIssues();
  }

  final headers = {'Content-Type': 'application/json'};
  bool isColor = false;

  final EnumAliaser aliaser = new EnumAliaser();

  List<FullIssueInfoResponse> systemIssuesList = [
    FullIssueInfoResponse(
        issueId: 1,
        issueType: 'd',
        issueStatus: 'a',
        title: 'd',
        description: 'd',
        imgLink: 'd',
        createMoment: 'd',
        userName: 'kirill'
    )
  ];

  Future<void> getSystemIssues() async {

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null){
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();

      var model = new UserInfoRequestModel(userId: userId, token: token);
      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/issues/get_all_issues';

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
          var userIssues = data['issues'];

          var fetchedIssues =
          List<FullIssueInfoResponse>
              .from(userIssues.map(
                  (data) => FullIssueInfoResponse.fromJson(data)));

          setState(() {
            systemIssuesList = fetchedIssues;
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
          title: Text('Список всех открытых проблемных запросов'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SystemAdminPageWidget(userName: 'Kirill')),);
            },
          ),
        ),
        body: systemIssuesList.length == 0
            ? Column(
          children: [
            SizedBox(height: 16.0),
            Text(
                'Нет ни одного открытого запроса',
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 26),
                textAlign: TextAlign.center),
            SizedBox(height: 16.0),
          ],
        )
            : ListView.builder(
          itemCount: systemIssuesList.length,
          itemBuilder: (context, index) {
            final data = systemIssuesList[index];
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
                    children: [
                      Text(
                        'Пользователь, создавший запрос: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        utf8.decode(utf8.encode(data.userName)),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        'Заголовок запроса: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        utf8.decode(utf8.encode(data.title)),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        'Тип запроса: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                          aliaser.GetAlias(
                              aliaser.getIssueTypeEnumValue(data.issueType)),
                          style: TextStyle(
                            color: Colors.white,
                          )
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Статус запроса: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                          aliaser.GetAlias(
                              aliaser.getIssueStatusEnumValue(data.issueStatus)),
                          style: TextStyle(
                            color: Colors.white,
                          )
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Описание запроса: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        utf8.decode(utf8.encode(data.description)),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      /*
                      Image.network(utf8.decode(utf8.encode(data.imgLink)), scale: 0.01),
                      SizedBox(height: 12.0),
                      */
                      Text(
                        'Время создания запроса: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        utf8.decode(data.createMoment.codeUnits),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        child: Text('Просмотреть запрос'),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context)
                            => SingleIssuePageWidget(issueId: data.issueId, isSelfUser: false,)),
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