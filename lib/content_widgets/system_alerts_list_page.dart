import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/EnumAliaser.dart';
import 'package:todo_calendar_client/main_widgets/system_admin_page.dart';
import 'package:todo_calendar_client/models/requests/UserInfoRequestModel.dart';
import 'package:todo_calendar_client/models/responses/AlertInfoResponse.dart';
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

class SystemAlertsListPageWidget extends StatefulWidget {
  const SystemAlertsListPageWidget({super.key});


  @override
  SystemAlertsListPageState createState() => SystemAlertsListPageState();
}

class SystemAlertsListPageState extends State<SystemAlertsListPageWidget> {

  @override
  void initState() {
    super.initState();
    getSystemAlerts();
  }

  bool isServerDataLoaded = true;

  final headers = {'Content-Type': 'application/json'};
  bool isColor = false;

  final EnumAliaser aliaser = new EnumAliaser();

  List<AlertInfoResponse> systemAlertsList = [
    AlertInfoResponse(
        alertId: 1,
        title: 'd',
        description: 'd',
        moment: 'd',
        isAlerted: false
    )
  ];

  String currentHost = GlobalEndpoints().mobileUri;

  Future<void> getSystemAlerts() async {

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    setState(() {
      isServerDataLoaded = false;
    });

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null){
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      setState(() {
        currentHost = cacheContent.currentHost;
      });

      var userId = cacheContent.userId;
      var token = cacheContent.firebaseToken.toString();

      var model = new UserInfoRequestModel(userId: userId, token: token);
      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var requestString = '/alerts/get_all_alerts';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentHost + currentPort + requestString);

      final body = jsonEncode(requestMap);

      try {
        final response = await http.post(url, headers: headers, body: body);

        var jsonData = jsonDecode(response.body);
        var responseContent = GetResponse.fromJson(jsonData);

        if (responseContent.result) {
          var userRequestedInfo = responseContent.requestedInfo.toString();

          var data = jsonDecode(userRequestedInfo);
          var userAlerts = data['alerts'];

          var fetchedAlerts =
          List<AlertInfoResponse>
              .from(userAlerts.map(
                  (data) => AlertInfoResponse.fromJson(data)));

          setState(() {
            systemAlertsList = fetchedAlerts;
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
          title: Text('Список всех алертов системы',
            style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
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
        body: systemAlertsList.length == 0
            ? Column(
          children: 
          !isServerDataLoaded
          ? [Center(
            child: SpinKitCircle(
              size: 100,
              color: Colors.deepPurple, 
              duration: Durations.medium1,) )]
          : [
            SizedBox(height: 16.0),
            Text(
                'Нет ни одного системного алерта',
                style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
                textAlign: TextAlign.center),
            SizedBox(height: 16.0),
          ],
        )
            : ListView.builder(
          itemCount: systemAlertsList.length,
          itemBuilder: (context, index) {
            final data = systemAlertsList[index];
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
                    children: !isServerDataLoaded
                  ? [Center(
                      child: SpinKitCircle(
                        size: 100,
                        color: Colors.deepPurple, 
                        duration: Durations.medium1,) )]
                  : [
                      Text(
                        'Заголовок алерта: ',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      Text(
                        utf8.decode(utf8.encode(data.title)),
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        'Алерт был просмотрен админом: ',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      Text(
                        utf8.decode(utf8.encode(data.isAlerted.toString())),
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Описание ошибки в алерте: ',
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
                      SizedBox(height: 12.0),
                      Text(
                        'Время возниковения алерта: ',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      Text(
                        utf8.decode(data.moment.codeUnits),
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      SizedBox(height: 8.0),
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