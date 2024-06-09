import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/content_widgets/events_list_page.dart';
import 'package:todo_calendar_client/models/requests/EditExistingEventModel.dart';
import 'package:todo_calendar_client/models/requests/EventInfoRequest.dart';
import 'package:todo_calendar_client/models/responses/EventInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/ShortUserInfoResponse.dart';
import 'package:todo_calendar_client/shared_pref_cached_data.dart';
import 'dart:convert';
import 'package:todo_calendar_client/models/requests/AddNewEventModel.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';
import '../../GlobalEndpoints.dart';
import '../../models/responses/additional_responces/GetResponse.dart';
import '../../models/responses/additional_responces/ResponseWithToken.dart';

class SingleEventPageWidget extends StatefulWidget {
  final int eventId;

  SingleEventPageWidget({required this.eventId});

  @override
  SingleEventPageState createState() {
    return new SingleEventPageState(eventId: eventId, isPageJustLoaded: true);
  }
}

class SingleEventPageState extends State<SingleEventPageWidget> {
  final int eventId;

  SingleEventPageState({required this.eventId, required this.isPageJustLoaded});

  @override
  void initState() {
    super.initState();
    getCertainEventInfo(eventId);
  }

  bool isPageJustLoaded;

  bool isBeginTimeChanged = false;
  bool isEndTimeChanged = false;

  final int groupId = 10;
  late String token;

  bool isCaptionValidated = true;
  bool isDescriptionValidated = true;

  bool isEventEndTimeGreaterThanBeginTime = true;
  bool isEventDurationValidated = true;

  final TextEditingController eventCaptionController = TextEditingController();
  final TextEditingController eventDescriptionController =
      TextEditingController();

  final headers = {'Content-Type': 'application/json'};

  @override
  void dispose() {
    eventCaptionController.dispose();
    eventDescriptionController.dispose();
    super.dispose();
  }

  EventInfoResponse event = new EventInfoResponse(
      eventId: 1,
      caption: '1',
      description: '2',
      start: '3',
      duration: '4',
      eventType: '5',
      eventStatus: '6');

  String currentHost = GlobalEndpoints().mobileUri;

  Future<UsersListsContent?> getCertainEventInfo(int eventId) async {
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

      var model =
          new EventInfoRequest(userId: userId, token: token, eventId: eventId);
      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var requestString = '/events/get_event_info';

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

          setState(() {
            scheduledStart = EventInfoResponse.fromJson(data).start;
          });

          var rawBeginIndex = userRequestedInfo.indexOf('"guests"');
          var rawEndIndex = userRequestedInfo.indexOf(']}') + 2;

          var string = '{' +
              userRequestedInfo.substring(rawBeginIndex, rawEndIndex) +
              '}';

          var contentData = jsonDecode(string);

          var eventParticipants = contentData['guests'];

          var fetchedEventUsers = List<ShortUserInfoResponse>.from(
              eventParticipants
                  .map((data) => ShortUserInfoResponse.fromJson(data)));

          rawBeginIndex = userRequestedInfo.indexOf('"participants"');
          rawEndIndex = userRequestedInfo.indexOf(']}') + 2;

          string =
              '{' + userRequestedInfo.substring(rawBeginIndex, rawEndIndex);

          contentData = jsonDecode(string);

          var groupUsers = contentData['participants'];

          var fetchedGroupUsers = List<ShortUserInfoResponse>.from(
              groupUsers.map((data) => ShortUserInfoResponse.fromJson(data)));

          List<ShortUserInfoResponse> remainingGroupUsers = [];

          fetchedGroupUsers.forEach((element) {
            if (!fetchedEventUsers
                .any((element1) => element1.userId == element.userId)) {
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

  Future<void> editExistedEvent(BuildContext context) async {
    String caption = eventCaptionController.text;
    String description = eventDescriptionController.text;
    String scheduledStart = selectedBeginDateTime.toString();

    int durationMs = selectedEndDateTime.millisecondsSinceEpoch >
            selectedBeginDateTime.millisecondsSinceEpoch
        ? selectedEndDateTime.difference(selectedBeginDateTime).inMilliseconds
        : DateTime(0, 0, 0, 0, 30, 0).millisecondsSinceEpoch;

    var durationSeconds = (durationMs / 1000).round();

    var hours = (durationSeconds / 3600).round();

    var remainingSeconds = durationSeconds - hours * 3600;

    var minutes = (remainingSeconds / 60).round();

    var seconds = remainingSeconds - minutes * 60;

    var duration = hours.toString().padLeft(2, '0') +
        ':' +
        minutes.toString().padLeft(2, '0') +
        ':' +
        seconds.toString().padLeft(2, '0');

    // TODO: реализовать корректное добавление пользователей
    var guestIds = [2];

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

      var model = new EditExistingEventModel(
          userId: userId,
          token: token,
          eventId: eventId,
          caption: caption,
          description: description,
          start: scheduledStart,
          duration: duration,
          eventType: selectedEventType,
          eventStatus: selectedEventStatus);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var requestString = '/events/update_event_params';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentHost + currentPort + requestString);

      final headers = {'Content-Type': 'application/json'};
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

        eventCaptionController.clear();
        eventDescriptionController.clear();

        setState(() {
          getCertainEventInfo(eventId);
        });
      } catch (e) {
        if (e is TimeoutException) {
          //treat TimeoutException
          print("Timeout exception: ${e.toString()}");
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка!'),
          content: Text('Изменение существующего мероприятия не произошло!'),
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

  bool isServerDataLoaded = false;

  @override
  Widget build(BuildContext context) {
    var showingBeginHours =
        selectedBeginDateTime.hour.toString().padLeft(2, '0');
    var showingBeginMinutes =
        selectedBeginDateTime.minute.toString().padLeft(2, '0');

    var showingEndHours = selectedEndDateTime.hour.toString().padLeft(2, '0');
    var showingEndMinutes =
        selectedEndDateTime.minute.toString().padLeft(2, '0');

    if (isPageJustLoaded) {
      selectedBeginDateTime = DateTime.now();
      selectedEndDateTime = DateTime.now();
      isPageJustLoaded = false;

      if (!isBeginTimeChanged) {
        showingBeginHours =
            (selectedBeginDateTime.hour + 1).toString().padLeft(2, '0');
        showingBeginMinutes = 0.toString().padLeft(2, '0');
      }

      if (!isEndTimeChanged) {
        showingEndHours =
            (selectedEndDateTime.hour + 1).toString().padLeft(2, '0');
        showingEndMinutes = 0.toString().padLeft(2, '0');
      }
    }

    final eventTypes = ['None', 'Personal', 'OneToOne', 'StandUp', 'Meeting'];
    final eventStatuses = [
      'None',
      'NotStarted',
      'WithinReminderOffset',
      'Live',
      'Finished',
      'Cancelled'
    ];

    outputBeginDateTime = '${selectedBeginDateTime.year}'
        '/${selectedBeginDateTime.month}'
        '/${selectedBeginDateTime.day}'
        ' $showingBeginHours'
        ':$showingBeginMinutes';

    outputEndDateTime = '${selectedEndDateTime.year}'
        '/${selectedEndDateTime.month}'
        '/${selectedEndDateTime.day}'
        ' $showingEndHours'
        ':$showingEndMinutes';

    Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: selectedBeginDateTime,
        firstDate: DateTime(2023),
        lastDate: DateTime(2025));

    Future<TimeOfDay?> pickTime() => showTimePicker(
        context: context,
        initialTime:
            TimeOfDay(hour: selectedBeginDateTime.hour + 1, minute: 0));

    Future pickBeginDateTime() async {
      DateTime? date = await pickDate();
      if (date == null) return;

      final time = await pickTime();

      if (time == null) return;

      final newDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      setState(() {
        selectedBeginDateTime = newDateTime;
      });
    }

    Future pickEndDateTime() async {
      DateTime? date = await pickDate();
      if (date == null) return;

      final time = await pickTime();

      if (time == null) return;

      final newDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);

      setState(() {
        selectedEndDateTime = newDateTime;
      });
    }

    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
        home: Scaffold(
            appBar: AppBar(
              title: Text(
                'Страничка просмотра информации о событии',
                style: TextStyle(fontSize: 16, color: Colors.deepPurple),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EventsListPageWidget()),
                  );
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
                              'Просмотр текущего события:',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple),
                            ),
                            SizedBox(height: 30.0),
                            SizedBox(height: 16.0),
                            TextField(
                              controller: eventCaptionController,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.deepPurple),
                              decoration: InputDecoration(
                                  labelText: 'Наименование мероприятия:',
                                  labelStyle: TextStyle(
                                      fontSize: 16, color: Colors.deepPurple),
                                  errorText: !isCaptionValidated
                                      ? 'Название мероприятия не может быть пустым'
                                      : null),
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: eventDescriptionController,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.deepPurple),
                              maxLines: null,
                              decoration: InputDecoration(
                                  labelText: 'Описание меропрития:',
                                  labelStyle: TextStyle(
                                      fontSize: 16.0, color: Colors.deepPurple),
                                  errorText: !isDescriptionValidated
                                      ? 'Описание мероприятия не может быть пустым'
                                      : null),
                            ),
                            SizedBox(height: 20.0),
                            Text(
                              'Время начала мероприятия',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.deepPurple),
                            ),
                            SizedBox(height: 12.0),
                            ElevatedButton(
                              child: Text(
                                outputBeginDateTime,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.deepPurple),
                              ),
                              onPressed: () async {
                                await pickBeginDateTime();
                                setState(() {
                                  isBeginTimeChanged = true;
                                  outputBeginDateTime =
                                      '${selectedBeginDateTime.year}'
                                      '/${selectedBeginDateTime.month}'
                                      '/${selectedBeginDateTime.day}'
                                      ' ${selectedBeginDateTime.hour}'
                                      ':${selectedBeginDateTime.minute}';

                                  isEventEndTimeGreaterThanBeginTime =
                                      selectedEndDateTime
                                              .millisecondsSinceEpoch >
                                          selectedBeginDateTime
                                              .millisecondsSinceEpoch;

                                  isEventDurationValidated =
                                      (selectedEndDateTime
                                              .difference(selectedBeginDateTime)
                                              .inMilliseconds) <
                                          (3600 * 24 * 1000);
                                });
                              },
                            ),
                            SizedBox(height: 24.0),
                            Text(
                              'Время окончания мероприятия',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.deepPurple),
                            ),
                            SizedBox(height: 12.0),
                            TextButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isEventDurationValidated &&
                                        isEventEndTimeGreaterThanBeginTime
                                    ? Colors.green
                                    : Colors.red,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.cyan,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                minimumSize: Size(250, 100),
                              ),
                              child: isEventDurationValidated &&
                                      isEventEndTimeGreaterThanBeginTime
                                  ? Text(outputEndDateTime)
                                  : !isEventEndTimeGreaterThanBeginTime
                                      ? Text('Время окончания ' +
                                          outputEndDateTime +
                                          ' должно быть больше времени начала')
                                      : Text('Время окончания ' +
                                          outputEndDateTime +
                                          ' должно быть не позже 24 часов после начала'),
                              onPressed: () async {
                                await pickEndDateTime();
                                setState(() {
                                  isEndTimeChanged = true;
                                  outputBeginDateTime =
                                      '${selectedEndDateTime.year}'
                                      '/${selectedEndDateTime.month}'
                                      '/${selectedEndDateTime.day}'
                                      ' ${selectedEndDateTime.hour}'
                                      ':${selectedEndDateTime.minute}';

                                  isEventEndTimeGreaterThanBeginTime =
                                      selectedEndDateTime
                                              .millisecondsSinceEpoch >
                                          selectedBeginDateTime
                                              .millisecondsSinceEpoch;

                                  isEventDurationValidated =
                                      (selectedEndDateTime
                                              .difference(selectedBeginDateTime)
                                              .inMilliseconds) <
                                          (3600 * 24 * 1000);
                                });
                              },
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'Тип мероприятия',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.deepPurple),
                            ),
                            SizedBox(height: 4.0),
                            DropdownButtonFormField(
                                value: selectedEventType,
                                items: eventTypes.map((String type) {
                                  return DropdownMenuItem(
                                      value: type, child: Text(type));
                                }).toList(),
                                onChanged: (String? newType) {
                                  setState(() {
                                    selectedEventType = newType.toString();
                                  });
                                }),
                            SizedBox(height: 20.0),
                            Text(
                              'Статус мероприятия',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.deepPurple),
                            ),
                            SizedBox(height: 4.0),
                            DropdownButtonFormField(
                                value: selectedEventStatus,
                                items: eventStatuses.map((String status) {
                                  return DropdownMenuItem(
                                      value: status, child: Text(status));
                                }).toList(),
                                onChanged: (String? newStatus) {
                                  setState(() {
                                    selectedEventStatus = newStatus.toString();
                                  });
                                }),
                            SizedBox(height: 30.0),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  getCertainEventInfo(eventId).then((value) {
                                    UsersListsContent content = value!;

                                    var eventUsers = content.eventUsers;
                                    var groupUsers =
                                        content.remainingGroupUsers;

                                    var builder = StringBuffer();

                                    eventUsers.forEach((element) {
                                      builder.write(element.userName +
                                          ' (' +
                                          element.userEmail +
                                          ')\n');
                                    });

                                    certainEventUsersDescription =
                                        builder.toString();

                                    builder.clear();

                                    groupUsers.forEach((element) {
                                      builder.write(element.userName +
                                          ' (' +
                                          element.userEmail +
                                          ')\n');
                                    });

                                    certainEventUsersFromGroupDescription =
                                        builder.toString();

                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Container(
                                                child: new Text('Meet')),
                                            content: Container(
                                                height: 300,
                                                width: 500,
                                                child: Padding(
                                                    padding:
                                                        EdgeInsets.all(6.0),
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        children: <Widget>[
                                                          Row(
                                                            children: <Widget>[
                                                              Text(
                                                                'Дата и время события:',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .deepPurple,
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
                                                                scheduledStart,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .deepPurple,
                                                                  fontSize: 18,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: <Widget>[
                                                              Text('All day',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          18,
                                                                      color: Colors
                                                                          .deepPurple)),
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
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Colors
                                                                          .deepPurple,
                                                                      fontSize:
                                                                          18)),
                                                              SizedBox(
                                                                  height: 6.0)
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  certainEventUsersDescription,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300,
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .deepPurple))
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
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Colors
                                                                          .deepPurple,
                                                                      fontSize:
                                                                          18)),
                                                              SizedBox(
                                                                  height: 6.0)
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  certainEventUsersFromGroupDescription,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300,
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .deepPurple))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ))),
                                            actions: <Widget>[
                                              new ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: new Text(
                                                    'ОК',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color:
                                                            Colors.deepPurple),
                                                  ))
                                            ],
                                          );
                                        });
                                  });
                                });
                              },
                              child: Text('Подробнее о мероприятии'),
                            ),
                            SizedBox(height: 30.0),
                            ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  isCaptionValidated =
                                      !eventCaptionController.text.isEmpty;
                                  isDescriptionValidated =
                                      !eventDescriptionController.text.isEmpty;

                                  isEventEndTimeGreaterThanBeginTime =
                                      selectedEndDateTime
                                              .millisecondsSinceEpoch >
                                          selectedBeginDateTime
                                              .millisecondsSinceEpoch;

                                  isEventDurationValidated =
                                      (selectedEndDateTime
                                              .difference(selectedBeginDateTime)
                                              .inMilliseconds) <
                                          (3600 * 24 * 1000);

                                  if (isCaptionValidated &&
                                      isDescriptionValidated &&
                                      isEventDurationValidated &&
                                      isEventEndTimeGreaterThanBeginTime) {
                                    editExistedEvent(context);
                                  }
                                });
                              },
                              child: Text(
                                'Изменить текущее мероприятие',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.deepPurple),
                              ),
                            ),
                          ],
                  ),
                ))));
  }

  String certainEventUsersDescription = '';
  String certainEventUsersFromGroupDescription = '';

  String scheduledStart = '1';

  String selectedEventType = "None";
  String selectedEventStatus = "None";

  DateTime selectedBeginDateTime = DateTime.now();
  DateTime selectedEndDateTime = DateTime.now();

  String outputBeginDateTime = '';
  String outputEndDateTime = '';

  String existedCaption = '';
  String existedDescription = '';
}
