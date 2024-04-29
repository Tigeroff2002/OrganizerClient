import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/EnumAliaser.dart';
import 'package:todo_calendar_client/content_widgets/snapshots_list_page.dart';
import 'dart:convert';
import 'package:todo_calendar_client/models/requests/AddNewTaskModel.dart';
import 'package:todo_calendar_client/models/requests/EditExistingTaskModel.dart';
import 'package:todo_calendar_client/models/requests/SnapshotInfoRequest.dart';
import 'package:todo_calendar_client/models/requests/TaskInfoRequest.dart';
import 'package:todo_calendar_client/models/responses/CommonSnapshotInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/GroupSnapshotInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/PersonalSnapshotInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';
import 'package:todo_calendar_client/content_widgets/tasks_list_page.dart';
import '../../GlobalEndpoints.dart';
import '../../models/responses/additional_responces/GetResponse.dart';
import '../../models/responses/additional_responces/ResponseWithToken.dart';
import '../../shared_pref_cached_data.dart';

class SinglePersonalSnapshotPageWidget extends StatefulWidget{

  final int snapshotId;

  SinglePersonalSnapshotPageWidget({required this.snapshotId});

  @override
  SinglePersonalSnapshotPageState createState(){
    return new SinglePersonalSnapshotPageState(snapshotId: snapshotId);
  }
}


class SinglePersonalSnapshotPageState extends State<SinglePersonalSnapshotPageWidget> {

  final int snapshotId;

      PersonalSnapshotInfoResponse snapshot = 
      PersonalSnapshotInfoResponse(
        snapshotId: 1,
        snapshotType: 'd',
        auditType: '1',
        beginMoment: 'e',
        endMoment: 'df',
        content: 'd',
        KPI: 1.0,
        creationTime: 'd');

  bool isDiagramMode = false;

  SinglePersonalSnapshotPageState({required this.snapshotId});

    @override
    void initState() {
      super.initState();
      getExistedSnapshot(context);
  }

  Future<void> getExistedSnapshot(BuildContext context) async
  {
    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();

      var model = new SnapshotInfoRequest(userId: userId, token: token, snapshotId: snapshotId);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/snapshots/get_snapshot_info';

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

            print(userRequestedInfo);

            setState(() {
              snapshot = PersonalSnapshotInfoResponse.fromJson(data);
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

  final EnumAliaser aliaser = new EnumAliaser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Страничка персонального отчета под номером ' + snapshotId.toString()),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SnapshotsListPageWidget()),);
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
                        'Информация о текущем снапшоте',
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 30.0),
                      Text(
                        'Тип снапшота: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        aliaser.GetAlias(
                            aliaser.getSnapshotTypeEnumValue(snapshot.snapshotType)),
                        style: TextStyle(
                          color: Colors.white,
                        )
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Аудит снапшота: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        aliaser.GetAlias(
                            aliaser.getSnapshotTypeEnumValue(snapshot.auditType)),
                        style: TextStyle(
                          color: Colors.white,
                        )
                      ),
                        SizedBox(height: 8.0),
                        Text(
                          'Время создания снапшота: ',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          utf8.decode(snapshot.creationTime.codeUnits),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                      Text(
                        'Время, взятое для начала снапшота: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        utf8.decode(snapshot.beginMoment.codeUnits),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Время, взятое для окончания снапшота: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        utf8.decode(snapshot.endMoment.codeUnits),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.0),
                      Text(
                        'Коэффициент KPI по результатам отчета: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        utf8.decode(utf8.encode(snapshot.KPI.toString())),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.0),
                      Text(
                        'Информация, полученная в снапшоте: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        utf8.decode(utf8.encode(snapshot.content)),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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