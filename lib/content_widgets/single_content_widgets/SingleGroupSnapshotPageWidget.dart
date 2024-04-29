import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/EnumAliaser.dart';
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

class SingleGroupSnapshotPageWidget extends StatefulWidget{

  final int snapshotId;
  final int groupId;

  SingleGroupSnapshotPageWidget({required this.snapshotId, required this.groupId});

  @override
  SingleGroupSnapshotPageState createState(){
    return new SingleGroupSnapshotPageState(snapshotId: snapshotId, groupId: groupId);
  }
}

class SingleGroupSnapshotPageState extends State<SingleGroupSnapshotPageWidget> {

  final int snapshotId;
  final int groupId;

      GroupSnapshotInfoResponse groupSnapshot = 
      new GroupSnapshotInfoResponse(
        snapshotType: 'd',
        auditType: '1',
        beginMoment: 'e',
        endMoment: 'df',
        creationTime: '1',
        groupId: 1,
        participantsKPIS: [],
        averageKPI: 1.0,
        content: 'd',);   

  SingleGroupSnapshotPageState({required this.snapshotId, required this.groupId});

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

            print(userRequestedInfo);

            var data = jsonDecode(userRequestedInfo);

            setState(() {
              groupSnapshot = GroupSnapshotInfoResponse.fromJson(data);
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

    setState(() {
      getExistedSnapshot(context);
    });

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Страничка отчета под номером ' + snapshotId.toString()
             + ' для группы ' + groupId.toString()),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
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
                            aliaser.getSnapshotTypeEnumValue(groupSnapshot.snapshotType)),
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
                            aliaser.getSnapshotTypeEnumValue(groupSnapshot.auditType)),
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
                          utf8.decode(groupSnapshot.creationTime.codeUnits),
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
                        utf8.decode(groupSnapshot.beginMoment.codeUnits),
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
                        utf8.decode(groupSnapshot.endMoment.codeUnits),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.0),
                      Text(
                        'Cредний коэффициент KPI по результатам отчета: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        utf8.decode(utf8.encode(groupSnapshot.averageKPI.toString())),
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
                        utf8.decode(utf8.encode(groupSnapshot.content)),
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