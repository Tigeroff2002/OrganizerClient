import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/EnumAliaser.dart';
import 'package:todo_calendar_client/add_widgets/AddGroupSnapshotWidget.dart';
import 'package:todo_calendar_client/content_widgets/single_content_widgets/SingleGroupSnapshotPageWidget.dart';
import 'package:todo_calendar_client/models/requests/GroupInfoRequest.dart';
import 'package:todo_calendar_client/models/requests/SnapshotInfoRequest.dart';
import 'package:todo_calendar_client/models/requests/UserInfoRequestModel.dart';
import 'package:todo_calendar_client/models/responses/GroupSnapshotInfoResponse.dart';
import 'dart:convert';
import 'package:todo_calendar_client/models/responses/additional_responces/GetResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';
import 'package:todo_calendar_client/shared_pref_cached_data.dart';
import 'package:todo_calendar_client/main_widgets/user_page.dart';
import 'package:todo_calendar_client/GlobalEndpoints.dart';
import 'package:todo_calendar_client/add_widgets/AddPersonalSnapshotWidget.dart';
import 'package:todo_calendar_client/models/responses/PersonalSnapshotInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithToken.dart';

class GroupManagerPageWidget extends StatefulWidget {

  final int groupId;

  GroupManagerPageWidget({required this.groupId});

  @override
  GroupManagerPageState createState() => GroupManagerPageState(groupId: groupId);
}

class GroupManagerPageState extends State<GroupManagerPageWidget> {

  final int groupId;

  @override
  void initState() {
    super.initState();
    getGroupSnapshotsInfo();
  }

  GroupManagerPageState({required this.groupId});

  final headers = {'Content-Type': 'application/json'};

  bool isColor = false;

  final EnumAliaser aliaser = new EnumAliaser();

  List<GroupSnapshotInfoResponse> groupSnapshotsList = [
    GroupSnapshotInfoResponse(
      snapshotId: 1,
      snapshotType: 'd',
      auditType: '1',
      beginMoment: 'e',
      endMoment: 'df',
      creationTime: '1',
      content: 'd',
      groupId: 1,
      participantsKPIS: List.empty(),
      averageKPI: 1.0
    )
  ];

  bool isServerDataLoaded = false;

  String currentHost = GlobalEndpoints().mobileUri;

  Future<void> getGroupSnapshotsInfo() async {

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
      var token = cacheContent.token.toString();

      var model = new GroupInfoRequest(userId: userId, token: token, groupId: groupId);
      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var requestString = '/snapshots/get_group_snapshots';

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
          var groupSnapshots = data['group_snapshots'];

          var fetchedSnapshots =
          List<GroupSnapshotInfoResponse>
              .from(groupSnapshots.map(
                  (data) => GroupSnapshotInfoResponse.fromJson(data)));

          setState(() {
            groupSnapshotsList = fetchedSnapshots;
            isServerDataLoaded = true;
          });
        }
      }
      catch (e) {
        if (e is TimeoutException) {
          //treat TimeoutException
          print("Timeout exception: ${e.toString()}");
        }
        else{
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

  Future<void> deleteSnapshot(int deletionSnapshotId) async {
    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null){
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      setState(() {
        currentHost = cacheContent.currentHost;
      });

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();

      var model = new SnapshotInfoRequest(
          userId: userId,
          token: token,
          snapshotId: deletionSnapshotId);

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
                SnackBar(
                    content: Text(responseContent.outInfo.toString())
                )
            );
          }

          setState(() {
            getGroupSnapshotsInfo();
          });
        }
      }
      catch (e) {
        if (e is TimeoutException) {
          //treat TimeoutException
          print("Timeout exception: ${e.toString()}");
        }
        else{
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
          title: Text('Список созданных снапшотов группы ',
            style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: groupSnapshotsList.length == 0
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
              'Вы пока не составили ни одного снапшота',
              style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
              textAlign: TextAlign.center),
            SizedBox(height: 16.0),
            ElevatedButton(
                child: Text('Создать новый снапшот для группы',
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context)
                      => AddGroupSnapshotWidget(groupId: groupId))
                  );
                })
          ],
        )
        : ListView.builder(
          itemCount: groupSnapshotsList.length,
          itemBuilder: (context, index) {
            final data = groupSnapshotsList[index];
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
                        'Тип снапшота: ',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      Text(
                        aliaser.GetAlias(
                            aliaser.getSnapshotTypeEnumValue(data.snapshotType)),
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        )
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Аудит снапшота: ',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      Text(
                        aliaser.GetAlias(
                            aliaser.getAuditTypeEnumValue(data.auditType)),
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        )
                      ),
                        SizedBox(height: 8.0),
                        Text(
                          'Время создания снапшота: ',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 16
                          ),
                        ),
                        Text(
                          utf8.decode(data.creationTime.codeUnits),
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 16
                          ),
                        ),
                        SizedBox(height: 8.0),
                      Text(
                        'Время, взятое для начала снапшота: ',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      Text(
                        utf8.decode(data.beginMoment.codeUnits),
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Время, взятое для окончания снапшота: ',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      Text(
                        utf8.decode(data.endMoment.codeUnits),
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      SizedBox(height: 12.0),
                      Text(
                        'Средний коэффициент KPI по результатам отчета: ',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      Text(
                        utf8.decode(utf8.encode(data.averageKPI.toString())),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurple
                        ),
                      ),
                      SizedBox(height: 12.0),
                      Text(
                        'Информация, полученная в снапшоте: ',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        ),
                      ),
                      Text(
                        utf8.decode(utf8.encode(data.content)),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurple
                        ),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        child: Text('Просмотреть снапшот группы',
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context)
                              => SingleGroupSnapshotPageWidget(snapshotId: data.snapshotId, groupId: groupId,)),
                          );
                        },
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        child: Text('Удалить снапшот',
                          style: TextStyle(fontSize: 16, color: Colors.deepOrange),),
                          onPressed: () {
                            deleteSnapshot(data.snapshotId).then((value) => {
                              groupSnapshotsList.removeWhere((element) => element.snapshotId == data.snapshotId)
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