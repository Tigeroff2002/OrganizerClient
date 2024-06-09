import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/EnumAliaser.dart';
import 'package:todo_calendar_client/content_widgets/single_content_widgets/SinglePersonalSnapshotPageWidget.dart';
import 'package:todo_calendar_client/content_widgets/user_info_map.dart';
import 'package:todo_calendar_client/models/requests/SnapshotInfoRequest.dart';
import 'package:todo_calendar_client/models/requests/UserInfoRequestModel.dart';
import 'dart:convert';
import 'package:todo_calendar_client/models/responses/additional_responces/GetResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';
import 'package:todo_calendar_client/shared_pref_cached_data.dart';
import 'package:todo_calendar_client/main_widgets/user_page.dart';
import 'package:todo_calendar_client/GlobalEndpoints.dart';
import 'package:todo_calendar_client/add_widgets/AddPersonalSnapshotWidget.dart';
import 'package:todo_calendar_client/models/responses/PersonalSnapshotInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithToken.dart';

class SnapshotsListPageWidget extends StatefulWidget {
  const SnapshotsListPageWidget({super.key});

  @override
  SnapshotsListPageState createState() => SnapshotsListPageState();
}

class SnapshotsListPageState extends State<SnapshotsListPageWidget> {
  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  final headers = {'Content-Type': 'application/json'};
  bool isColor = false;

  final EnumAliaser aliaser = new EnumAliaser();

  List<PersonalSnapshotInfoResponse> snapshotsList = [
    PersonalSnapshotInfoResponse(
        snapshotId: 1,
        snapshotType: 'd',
        auditType: '1',
        beginMoment: 'e',
        endMoment: 'df',
        KPI: 1.0,
        content: 'd',
        creationTime: 'd')
  ];

  bool isServerDataLoaded = false;

  String currentHost = GlobalEndpoints().mobileUri;

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

      var userId = cacheContent.userId;
      var token = cacheContent.firebaseToken.toString();

      var model = new UserInfoRequestModel(userId: userId, token: token);
      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var requestString = '/users/get_info';

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
          var userSnapshots = data['user_snapshots'];

          var fetchedSnapshots = List<PersonalSnapshotInfoResponse>.from(
              userSnapshots
                  .map((data) => PersonalSnapshotInfoResponse.fromJson(data)));

          setState(() {
            snapshotsList = fetchedSnapshots;
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

  Future<void> deleteSnapshot(int deletionSnapshotId) async {
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

      var model = new SnapshotInfoRequest(
          userId: userId, token: token, snapshotId: deletionSnapshotId);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var requestString = '/snapshots/delete_snapshot';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentHost + currentPort + requestString);

      final body = jsonEncode(requestMap);

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          var responseContent = Response.fromJson(jsonData);

          if (responseContent.outInfo != null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(responseContent.outInfo.toString())));
          }
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Список созданных вами личных снапшотов',
            style: TextStyle(fontSize: 16, color: Colors.deepPurple),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UserInfoMapPage()),
              );
            },
          ),
        ),
        body: snapshotsList.length == 0
            ? Column(
                children: !isServerDataLoaded
                    ? [
                        Center(
                            child: SpinKitCircle(
                          size: 100,
                          color: Colors.deepPurple,
                          duration: Durations.medium1,
                        ))
                      ]
                    : [
                        SizedBox(height: 16.0),
                        Text('Вы пока не составили ни одного снапшота',
                            style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                            textAlign: TextAlign.center),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                            child: Text(
                              'Создать новый личный снапшот',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.deepPurple),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AddPersonalSnapshotWidget(
                                              color: Colors.greenAccent,
                                              text: 'Создание нового снапшота',
                                              index: 5)));
                            })
                      ],
              )
            : ListView.builder(
                itemCount: snapshotsList.length,
                itemBuilder: (context, index) {
                  final data = snapshotsList[index];
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
                              ? [
                                  Center(
                                      child: SpinKitCircle(
                                    size: 100,
                                    color: Colors.deepPurple,
                                    duration: Durations.medium1,
                                  ))
                                ]
                              : [
                                  Text(
                                    'Тип снапшота: ',
                                    style: TextStyle(
                                        color: Colors.deepPurple, fontSize: 16),
                                  ),
                                  Text(
                                      aliaser.GetAlias(
                                          aliaser.getSnapshotTypeEnumValue(
                                              data.snapshotType)),
                                      style: TextStyle(
                                          color: Colors.deepPurple,
                                          fontSize: 16)),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Аудит снапшота: ',
                                    style: TextStyle(
                                        color: Colors.deepPurple, fontSize: 16),
                                  ),
                                  Text(
                                      aliaser.GetAlias(
                                          aliaser.getAuditTypeEnumValue(
                                              data.auditType)),
                                      style: TextStyle(
                                          color: Colors.deepPurple,
                                          fontSize: 16)),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Время создания снапшота: ',
                                    style: TextStyle(
                                        color: Colors.deepPurple, fontSize: 16),
                                  ),
                                  Text(
                                    utf8.decode(data.creationTime.codeUnits),
                                    style: TextStyle(
                                        color: Colors.deepPurple, fontSize: 16),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Время, взятое для начала снапшота: ',
                                    style: TextStyle(
                                        color: Colors.deepPurple, fontSize: 16),
                                  ),
                                  Text(
                                    utf8.decode(data.beginMoment.codeUnits),
                                    style: TextStyle(
                                        color: Colors.deepPurple, fontSize: 16),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Время, взятое для окончания снапшота: ',
                                    style: TextStyle(
                                        color: Colors.deepPurple, fontSize: 16),
                                  ),
                                  Text(
                                    utf8.decode(data.endMoment.codeUnits),
                                    style: TextStyle(
                                        color: Colors.deepPurple, fontSize: 16),
                                  ),
                                  SizedBox(height: 12.0),
                                  Text(
                                    'Коэффициент KPI по результатам отчета: ',
                                    style: TextStyle(
                                        color: Colors.deepPurple, fontSize: 16),
                                  ),
                                  Text(
                                    utf8.decode(
                                        utf8.encode(data.KPI.toString())),
                                    style: TextStyle(
                                        color: Colors.deepPurple, fontSize: 16),
                                  ),
                                  SizedBox(height: 12.0),
                                  Text(
                                    'Информация, полученная в снапшоте: ',
                                    style: TextStyle(
                                        color: Colors.deepPurple, fontSize: 16),
                                  ),
                                  Text(
                                    utf8.decode(utf8.encode(data.content)),
                                    style: TextStyle(
                                        color: Colors.deepPurple, fontSize: 16),
                                  ),
                                  SizedBox(height: 12),
                                  ElevatedButton(
                                    child: Text(
                                      'Просмотреть снапшот',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.deepPurple),
                                    ),
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SinglePersonalSnapshotPageWidget(
                                                  snapshotId: data.snapshotId,
                                                )),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 12),
                                  ElevatedButton(
                                    child: Text(
                                      'Удалить снапшот',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.deepOrange),
                                    ),
                                    onPressed: () {
                                      deleteSnapshot(data.snapshotId).then(
                                          (value) => {
                                                snapshotsList.removeWhere(
                                                    (element) =>
                                                        element.snapshotId ==
                                                        data.snapshotId)
                                              });
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
