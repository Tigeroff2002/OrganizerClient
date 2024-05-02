import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:todo_calendar_client/EnumAliaser.dart';
import 'package:todo_calendar_client/content_widgets/group_manager_page.dart';
import 'dart:convert';
import 'package:todo_calendar_client/models/requests/AddNewTaskModel.dart';
import 'package:todo_calendar_client/models/requests/EditExistingTaskModel.dart';
import 'package:todo_calendar_client/models/requests/SnapshotInfoRequest.dart';
import 'package:todo_calendar_client/models/requests/TaskInfoRequest.dart';
import 'package:todo_calendar_client/models/responses/CommonSnapshotInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/GroupParticipantKPIResponse.dart';
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
          snapshotId: 1,
          snapshotType: 'd',
          auditType: '1',
          beginMoment: 'e',
          endMoment: 'df',
          creationTime: '1',
          groupId: 1,
          participantsKPIS: [],
          averageKPI: 1.0,
          content: 'd',);   

  String currentHost = GlobalEndpoints().mobileUri;

  SingleGroupSnapshotPageState({required this.snapshotId, required this.groupId});

    @override
    void initState() {
      super.initState();
      getExistedSnapshot(context);
  }  

  Future<void> getExistedSnapshot(BuildContext context) async
  {
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
      var token = cacheContent.token.toString();

      var model = new SnapshotInfoRequest(userId: userId, token: token, snapshotId: snapshotId);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = currentHost;

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

            setState(() {
              groupSnapshot = GroupSnapshotInfoResponse.fromJson(data);

              var participantsKpis = 
                List<GroupParticipantKPIResponse>
                  .from(groupSnapshot.participantsKPIS.map(
                    (item) => GroupParticipantKPIResponse.fromJson(item)));

              histogramData = participantsKpis.map(
                (item) => new ParticipantKPIModel(
                  participantName: item.participantName,
                   kpi: item.participantKPI)).toList();

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

  bool isDiagramMode = false;

  bool isServerDataLoaded = false;

  @override
  Widget build(BuildContext context) {

    var modeTypes = ['Text', 'Diagram'];

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Страничка отчета под номером ' + snapshotId.toString()
             + ' для группы ' + groupId.toString(),
             style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => GroupManagerPageWidget(groupId: groupId)),);
            },
          ),
        ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: !isServerDataLoaded
                              ? [Center(
                                  child: SpinKitCircle(
                                size: 100,
                                color: Colors.deepPurple, 
                                duration: Durations.medium1,) )]
                              :  [
                      Text(
                        'Информация о текущем групповом снапшоте',
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                      SizedBox(height: 20.0),
              Text(
                'Тип отображения:',
                style: TextStyle(fontSize: 16, color: Colors.deepPurple),
              ),
              SizedBox(height: 4.0),
              DropdownButtonFormField(
                  value: selectedModeType,
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                  decoration: InputDecoration(
                    labelStyle: TextStyle(fontSize: 16, color: Colors.deepPurple)
                  ),
                  items: modeTypes.map((String type){
                    return DropdownMenuItem(
                        value: type,
                        child: Text(type));
                  }).toList(),
                  onChanged: (String? newType){
                    setState(() {
                      selectedModeType = newType.toString();
                      isDiagramMode = selectedModeType == 'Diagram';
                    });
                  }),  
                  SizedBox(height: 16.0),                   
                      Text(
                        'Тип снапшота: ',
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                      ),
                      Text(
                        aliaser.GetAlias(
                            aliaser.getSnapshotTypeEnumValue(groupSnapshot.snapshotType)),
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),
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
                            aliaser.getAuditTypeEnumValue(groupSnapshot.auditType)),
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                      ),
                        SizedBox(height: 8.0),
                        Text(
                          'Время создания снапшота: ',
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                        ),
                        Text(
                          utf8.decode(groupSnapshot.creationTime.codeUnits),
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                        ),
                        SizedBox(height: 8.0),
                      Text(
                        'Время, взятое для начала снапшота: ',
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                      ),
                      Text(
                        utf8.decode(groupSnapshot.beginMoment.codeUnits),
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Время, взятое для окончания снапшота: ',
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                      ),
                      Text(
                        utf8.decode(groupSnapshot.endMoment.codeUnits),
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                      ),
                      SizedBox(height: 12.0),
                      Text(
                        'Cредний коэффициент KPI по результатам отчета: ',
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                      ),
                      Text(
                        utf8.decode(utf8.encode(groupSnapshot.averageKPI.toString())),
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                      ),
                      SizedBox(height: 12.0),
                      Text(
                        'Информация, полученная в снапшоте: ',
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                      ),
                      !isDiagramMode
                      ? Text(
                        utf8.decode(utf8.encode(groupSnapshot.content)),
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                      )
                      : SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        series: <CartesianSeries>[
                          StackedColumnSeries<ParticipantKPIModel, String>(
                            dataSource: histogramData,
                            xValueMapper: (ParticipantKPIModel model, _) => model.participantName,
                            yValueMapper: (ParticipantKPIModel model, _) => model.kpi,)
                        ])
            ],
          ),
        ),
      ),
    ));
  }

  List<ParticipantKPIModel> histogramData = <ParticipantKPIModel>[];

  String selectedModeType = 'Text';
}

class ParticipantKPIModel {
  
  ParticipantKPIModel({
    required this.participantName, 
    required this.kpi});

  final String participantName;
  final double kpi;
}