import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:todo_calendar_client/EnumAliaser.dart';
import 'package:todo_calendar_client/content_widgets/single_content_widgets/SingleGroupPageWidget.dart';
import 'package:todo_calendar_client/models/EventAppointment.dart';
import 'package:todo_calendar_client/models/MeetingDataSource.dart';
import 'package:todo_calendar_client/models/requests/GroupParticipantCalendarRequest.dart';
import 'package:todo_calendar_client/models/requests/UserInfoRequestModel.dart';
import 'dart:convert';
import 'package:todo_calendar_client/models/responses/EventInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/GetResponse.dart';
import 'package:todo_calendar_client/shared_pref_cached_data.dart';
import 'package:todo_calendar_client/main_widgets/user_page.dart';
import 'package:todo_calendar_client/GlobalEndpoints.dart';
import 'package:todo_calendar_client/models/requests/EventInfoRequest.dart';
import 'package:todo_calendar_client/models/responses/ShortUserInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithToken.dart';

class ParticipantCalendarPageWidget extends StatefulWidget {

  final int groupId;
  final int participantId;
  final String participantName;

  ParticipantCalendarPageWidget(
      {
        required this.groupId,
        required this.participantId,
        required this.participantName
      });

  @override
  ParticipantCalendarPageState createState() =>
      new ParticipantCalendarPageState(
        groupId: groupId,
        participantId: participantId,
        participantName: participantName);
}

class ParticipantCalendarPageState extends State<ParticipantCalendarPageWidget> {

  @override
  void initState() {
    super.initState();
    getParticipantCalendarInfo();
  }

  String currentHost = GlobalEndpoints().mobileUri;

  final int groupId;
  final int participantId;
  final String participantName;

  ParticipantCalendarPageState(
      {
        required this.groupId,
        required this.participantId,
        required this.participantName
      });

  final headers = {'Content-Type': 'application/json'};
  bool isColor = false;

  final EnumAliaser aliaser = new EnumAliaser();

  List<EventInfoResponse> eventsList = [];

  bool isServerDataLoaded = false;

  Future<void> getParticipantCalendarInfo() async {

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

      var model = new GroupParticipantCalendarRequest(
          userId: userId,
          token: token,
          groupId: groupId,
          participantId: participantId);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = currentHost;

      var requestString = '/groups/get_participant_calendar';

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
          var userEvents = data['participant_events'];

          var fetchedEvents =
          List<EventInfoResponse>
              .from(userEvents.map(
                  (data) => EventInfoResponse.fromJson(data)));

          setState(() {
            eventsList = fetchedEvents;
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

  Future<UsersListsContent?> getCertainEventInfo(int eventId) async {

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

      var model = new EventInfoRequest(userId: userId, token: token, eventId: eventId);
      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = currentHost;

      var requestString = '/events/get_event_info';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentUri + currentPort + requestString);

      final body = jsonEncode(requestMap);

      try {
        final response = await http.post(url, headers: headers, body: body);

        var jsonData = jsonDecode(response.body);
        var responseContent = GetResponse.fromJson(jsonData);

        if (responseContent.result) {
          var userRequestedInfo = responseContent.requestedInfo.toString();

          var rawBeginIndex = userRequestedInfo.indexOf('"guests"');
          var rawEndIndex = userRequestedInfo.indexOf(']}') + 2;

          var string = '{' + userRequestedInfo.substring(rawBeginIndex, rawEndIndex) + '}';

          var contentData = jsonDecode(string);

          var eventParticipants = contentData['guests'];

          var fetchedEventUsers =
          List<ShortUserInfoResponse>
              .from(eventParticipants.map(
                  (data) => ShortUserInfoResponse.fromJson(data)));

          rawBeginIndex = userRequestedInfo.indexOf('"participants"');
          rawEndIndex = userRequestedInfo.indexOf(']}') + 2;

          string = '{' + userRequestedInfo.substring(rawBeginIndex, rawEndIndex);

          contentData = jsonDecode(string);

          var groupUsers = contentData['participants'];

          var fetchedGroupUsers =
          List<ShortUserInfoResponse>
              .from(groupUsers.map(
                  (data) => ShortUserInfoResponse.fromJson(data)));

          List<ShortUserInfoResponse> remainingGroupUsers = [];

          fetchedGroupUsers.forEach((element) {
            if (!fetchedEventUsers.any(
                    (element1) =>
                element1.userId == element.userId)){
              remainingGroupUsers.add(element);
            }
          });

          setState(() {
            isServerDataLoaded = true;
          });

          var content = new UsersListsContent(
              eventUsers: fetchedEventUsers,
              remainingGroupUsers: remainingGroupUsers);

          return content;
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

  List<Appointment> getAppointments(List<EventInfoResponse> fetchedEvents){
    MaterialColor color = Colors.blue;

    List<EventAppointment> meetings =
    List.from(
        fetchedEvents.map((data) =>
        new EventAppointment(
            data.eventId,
            data.start,
            data.duration,
            data.caption)));

    List<Appointment> appointments =
    List.from(
        meetings.map((data) =>
        new Appointment(
            id: data.eventId,
            startTime: data.startTime,
            endTime: data.endTime,
            subject: data.subject,
            color: color)));

    return appointments;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Календарь мероприятий одногруппника ' + participantName,
            style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SingleGroupPageWidget(groupId: groupId)),);
            },
          ),
        ),
        body: !isServerDataLoaded
        ? Center(
            child: SpinKitCircle(
            size: 100,
            color: Colors.deepPurple, 
            duration: Durations.medium1,) )
        : SfCalendar(
          view: CalendarView.day,
          firstDayOfWeek: 1,
          initialDisplayDate: DateTime.now(),
          initialSelectedDate: DateTime.now(),
          dataSource: MeetingDataSource(getAppointments(eventsList)),
          onTap: calendarTapped,
        ),
      ),
    );
  }

  void calendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment ||
        details.targetElement == CalendarElement.agenda) {
      final Appointment appointmentDetails = details.appointments![0];
      _subjectText = appointmentDetails.subject;
      _dateText = DateFormat('MMMM dd, yyyy')
          .format(appointmentDetails.startTime)
          .toString();
      _startTimeText =
          DateFormat('hh:mm a').format(appointmentDetails.startTime.add(Duration(hours: 3))).toString();
      _endTimeText =
          DateFormat('hh:mm a').format(appointmentDetails.endTime.add(Duration(hours: 3))).toString();
      _eventId = appointmentDetails.id.toString();

      int eventId = int.parse(_eventId);

      if (appointmentDetails.isAllDay) {
        _timeDetails = 'All day';
      } else {
        _timeDetails = '$_startTimeText - $_endTimeText';
      }

      setState(() {
        getCertainEventInfo(eventId).then((value) {
          UsersListsContent content = value!;

          var eventUsers = content.eventUsers;
          var groupUsers = content.remainingGroupUsers;

          var builder = StringBuffer();

          eventUsers.forEach((element) {
            builder.write(element.userName + ' (' + element.userEmail + ')\n');
          });

          certainEventUsersDescription = builder.toString();

          builder.clear();

          groupUsers.forEach((element) {
            builder.write(element.userName + ' (' + element.userEmail + ')\n');
          });

          certainEventUsersFromGroupDescription = builder.toString();

          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Container(child: new Text('$_subjectText')),
                  content: Container(
                      height: 200,
                      width: 500,
                      child: Padding(
                          padding: EdgeInsets.all(6.0),
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Дата и время события:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.deepPurple,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(''),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      '$_dateText',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.deepPurple,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(_timeDetails!,
                                        style: TextStyle(
                                            fontWeight: 
                                            FontWeight.w400,
                                             fontSize: 18,
                                             color: Colors.deepPurple)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(''),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                        'Список участников события: \n',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.deepPurple,
                                            fontSize: 18)),
                                    SizedBox(height: 6.0)
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                        certainEventUsersDescription,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14,
                                            color: Colors.deepPurple
                                        ))
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(''),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                        'Можно еще пригласить: \n',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.deepPurple,
                                            fontSize: 18)),
                                    SizedBox(height: 6.0)
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                        certainEventUsersFromGroupDescription,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14,
                                            color: Colors.deepPurple
                                        ))
                                  ],
                                ),
                              ],
                            ),
                          )
                      )
                  ),
                  actions: <Widget>[
                    new ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: new Text('ОК', style: TextStyle(fontSize: 16, color: Colors.deepPurple),))
                  ],
                );
              });
        });
      });
    }
  }

  String _timeDetails = '';
  String _dateText = '';
  String _subjectText = '';
  String _startTimeText = '';
  String _endTimeText = '';
  String _eventId = '';

  String certainEventUsersDescription = '';
  String certainEventUsersFromGroupDescription = '';
}

class UsersListsContent {
  final List<ShortUserInfoResponse> eventUsers;
  final List<ShortUserInfoResponse> remainingGroupUsers;

  UsersListsContent({
    required this.eventUsers,
    required this.remainingGroupUsers
  });
}
