import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
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

  SingleGroupSnapshotPageState({required this.snapshotId, required this.groupId});

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

            setState(() {
              groupSnapshot = GroupSnapshotInfoResponse.fromJson(data);
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

  @override
  Widget build(BuildContext context) {

    var modeTypes = ['Text', 'Diagram'];

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Страничка отчета под номером ' + snapshotId.toString()
             + ' для группы ' + groupId.toString()),
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
            children: [
                      Text(
                        'Информация о текущем снапшоте',
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20.0),
              Text(
                'Тип отображения:',
                style: TextStyle(fontSize: 16, color: Colors.deepPurple),
              ),
              SizedBox(height: 4.0),
              DropdownButtonFormField(
                  value: selectedModeType,
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
                      !isDiagramMode
                      ? Text(
                        utf8.decode(utf8.encode(groupSnapshot.content)),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : SfCartesianChart(series: <CartesianSeries>[
                    HistogramSeries<ChartData1, double>(
                    dataSource: histogramData,
                    showNormalDistributionCurve: true,
                    curveColor: const Color.fromRGBO(192, 108, 132, 1),
                    binInterval: 20,
                    yValueMapper: (ChartData1 data, _) => data.y)])
            ],
          ),
        ),
      ),
    );
  }

  final List<ChartData1> histogramData = <ChartData1>[
        ChartData1(5.250),
        ChartData1(7.750),
        ChartData1(0.0),
        ChartData1(8.275),
        ChartData1(9.750),
        ChartData1(7.750),
        ChartData1(8.275),
        ChartData1(6.250),
        ChartData1(5.750),
        ChartData1(5.250),
        ChartData1(23.000),
        ChartData1(26.500),
        ChartData1(26.500),
        ChartData1(27.750),
        ChartData1(25.025),
        ChartData1(26.500),
        ChartData1(28.025),
        ChartData1(29.250),
        ChartData1(26.750),
        ChartData1(27.250),
        ChartData1(26.250),
        ChartData1(25.250),
        ChartData1(34.500),
        ChartData1(25.625),
        ChartData1(25.500),
        ChartData1(26.625),
        ChartData1(36.275),
        ChartData1(36.250),
        ChartData1(26.875),
        ChartData1(40.000),
        ChartData1(43.000),
        ChartData1(46.500),
        ChartData1(47.750),
        ChartData1(45.025),
        ChartData1(56.500),
        ChartData1(56.500),
        ChartData1(58.025),
        ChartData1(59.250),
        ChartData1(56.750),
        ChartData1(57.250),
        ChartData1(46.250),
        ChartData1(55.250),
        ChartData1(44.500),
        ChartData1(45.525),
        ChartData1(55.500),
        ChartData1(46.625),
        ChartData1(46.275),
        ChartData1(56.250),
        ChartData1(46.875),
        ChartData1(43.000),
        ChartData1(46.250),
        ChartData1(55.250),
        ChartData1(44.500),
        ChartData1(45.425),
        ChartData1(55.500),
        ChartData1(56.625),
        ChartData1(46.275),
        ChartData1(56.250),
        ChartData1(46.875),
        ChartData1(43.000),
        ChartData1(46.250),
        ChartData1(55.250),
        ChartData1(44.500),
        ChartData1(45.425),
        ChartData1(55.500),
        ChartData1(46.625),
        ChartData1(56.275),
        ChartData1(46.250),
        ChartData1(56.875),
        ChartData1(41.000),
        ChartData1(63.000),
        ChartData1(66.500),
        ChartData1(67.750),
        ChartData1(65.025),
        ChartData1(66.500),
        ChartData1(76.500),
        ChartData1(78.025),
        ChartData1(79.250),
        ChartData1(76.750),
        ChartData1(77.250),
        ChartData1(66.250),
        ChartData1(75.250),
        ChartData1(74.500),
        ChartData1(65.625),
        ChartData1(75.500),
        ChartData1(76.625),
        ChartData1(76.275),
        ChartData1(66.250),
        ChartData1(66.875),
        ChartData1(80.000),
        ChartData1(85.250),
        ChartData1(87.750),
        ChartData1(89.000),
        ChartData1(88.275),
        ChartData1(89.750),
        ChartData1(97.750),
        ChartData1(98.275),
        ChartData1(96.250),
        ChartData1(95.750),
        ChartData1(95.250)
        ];

  String selectedModeType = 'Text';
}

class ChartData1 {
  ChartData1(this.y);
  final double y;
}