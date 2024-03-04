import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/content_widgets/events_list_page.dart';
import 'package:todo_calendar_client/models/requests/EditExistingEventModel.dart';
import 'package:todo_calendar_client/models/requests/EventInfoRequest.dart';
import 'package:todo_calendar_client/shared_pref_cached_data.dart';
import 'dart:convert';
import 'package:todo_calendar_client/models/requests/AddNewEventModel.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';
import '../GlobalEndpoints.dart';
import '../models/responses/additional_responces/GetResponse.dart';
import '../models/responses/additional_responces/ResponseWithToken.dart';

class EventEditingPageWidget extends StatefulWidget{

  final int eventId;

  EventEditingPageWidget({required this.eventId});

  @override
  EventEditingPageState createState(){
    return new EventEditingPageState(eventId: eventId, isPageJustLoaded: true);
  }
}

class EventEditingPageState extends State<EventEditingPageWidget> {

  final int eventId;

  EventEditingPageState({required this.eventId, required this.isPageJustLoaded});

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
  final TextEditingController eventDescriptionController = TextEditingController();

  @override
  void dispose() {
    eventCaptionController.dispose();
    eventDescriptionController.dispose();
    super.dispose();
  }

  Future<void> getExistedEvent(BuildContext context) async
  {
    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();

      var model = new EventInfoRequest(userId: userId, token: token, eventId: eventId);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/events/get_event_info';

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

          // TODO: необходимо провести десериализацию json-строки о пользователе

          setState(() {
            existedCaption = 'Старое название';
            existedDescription = 'Старое описание';

            eventCaptionController.text = existedCaption;
            eventDescriptionController.text = existedDescription;
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
          content: Text('Получение инфы о меоприятии не удалось!'),
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

  Future<void> editExistedEvent(BuildContext context) async
  {
    String caption = eventCaptionController.text;
    String description = eventDescriptionController.text;
    String scheduledStart = selectedBeginDateTime.toString();

    int durationMs =
    selectedEndDateTime.millisecondsSinceEpoch
        > selectedBeginDateTime.millisecondsSinceEpoch
        ? selectedEndDateTime.difference(selectedBeginDateTime).inMilliseconds
        : DateTime(0, 0, 0, 0, 30, 0).millisecondsSinceEpoch;

    var durationSeconds = (durationMs / 1000).round();

    var hours = (durationSeconds / 3600).round();

    var remainingSeconds = durationSeconds - hours * 3600;

    var minutes = (remainingSeconds / 60).round();

    var seconds = remainingSeconds - minutes * 60;

    var duration = hours.toString().padLeft(2, '0')
        + ':' + minutes.toString().padLeft(2, '0')
        + ':' + seconds.toString().padLeft(2, '0');

    // TODO: реализовать корректное добавление пользователей
    var guestIds = [2];

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null){
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();

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

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/events/update_event_params';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentUri + currentPort + requestString);

      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode(requestMap);

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200){

          var jsonData = jsonDecode(response.body);
          var responseContent = Response.fromJson(jsonData);
          if (responseContent.outInfo != null){
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(responseContent.outInfo.toString())
                )
            );
          }
        }

        eventCaptionController.clear();
        eventDescriptionController.clear();
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

  @override
  Widget build(BuildContext context) {

    setState(() {
      getExistedEvent(context);
    });

    var showingBeginHours = selectedBeginDateTime.hour.toString().padLeft(2, '0');
    var showingBeginMinutes = selectedBeginDateTime.minute.toString().padLeft(2, '0');

    var showingEndHours = selectedEndDateTime.hour.toString().padLeft(2, '0');
    var showingEndMinutes = selectedEndDateTime.minute.toString().padLeft(2, '0');

    if (isPageJustLoaded) {
      selectedBeginDateTime = DateTime.now();
      selectedEndDateTime = DateTime.now();
      isPageJustLoaded = false;

      if (!isBeginTimeChanged){
        showingBeginHours = (selectedBeginDateTime.hour + 1).toString().padLeft(2, '0');
        showingBeginMinutes = 0.toString().padLeft(2, '0');
      }

      if (!isEndTimeChanged){
        showingEndHours = (selectedEndDateTime.hour + 1).toString().padLeft(2, '0');
        showingEndMinutes = 0.toString().padLeft(2, '0');
      }
    }

    final eventTypes = ['None', 'Personal', 'OneToOne', 'StandUp', 'Meeting'];
    final eventStatuses = ['None', 'NotStarted', 'WithinReminderOffset', 'Live', 'Finished', 'Cancelled'];

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
        lastDate: DateTime(2025)
    );

    Future<TimeOfDay?> pickTime() => showTimePicker(
        context: context,
        initialTime: TimeOfDay(
            hour: selectedBeginDateTime.hour + 1,
            minute: 0));

    Future pickBeginDateTime() async {

      DateTime? date = await pickDate();
      if (date == null) return;

      final time = await pickTime();

      if (time == null) return;

      final newDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute
      );
      setState(() {
        selectedBeginDateTime = newDateTime;
      });
    }

    Future pickEndDateTime() async {

      DateTime? date = await pickDate();
      if (date == null) return;

      final time = await pickTime();

      if (time == null) return;

      final newDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute
      );

      setState(() {
        selectedEndDateTime = newDateTime;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Страничка редактирования задачи'),
        leading: IconButton(icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EventsListPageWidget()),);
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
                  'Изменение существующего мероприятия',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30.0),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: eventCaptionController,
                    decoration: InputDecoration(
                        labelText: 'Наименование мероприятия:',
                        labelStyle: TextStyle(fontSize: 16, color: Colors.deepPurple),
                        errorText: !isCaptionValidated
                            ? 'Название мероприятия не может быть пустым'
                            : null
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: eventDescriptionController,
                    maxLines: null,
                    decoration: InputDecoration(
                        labelText: 'Описание меропрития:',
                        labelStyle: TextStyle(
                            fontSize: 16.0,
                            color: Colors.deepPurple
                        ),
                        errorText: !isDescriptionValidated
                            ? 'Описание мероприятия не может быть пустым'
                            : null
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Время начала мероприятия',
                    style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 12.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor : Colors.white,
                      shadowColor: Colors.cyan,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      minimumSize: Size(250, 100),
                    ),
                    child: Text(outputBeginDateTime),
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
                            selectedEndDateTime.millisecondsSinceEpoch
                                > selectedBeginDateTime.millisecondsSinceEpoch;

                        isEventDurationValidated =
                            (selectedEndDateTime.difference(selectedBeginDateTime)
                                .inMilliseconds) < (3600 * 24 * 1000);
                      });
                    },
                  ),
                  SizedBox(height: 24.0),
                  Text(
                    'Время окончания мероприятия',
                    style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 12.0),
                  TextButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isEventDurationValidated && isEventEndTimeGreaterThanBeginTime
                          ? Colors.green
                          : Colors.red,
                      foregroundColor : Colors.white,
                      shadowColor: Colors.cyan,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      minimumSize: Size(250, 100),
                    ),
                    child:
                    isEventDurationValidated && isEventEndTimeGreaterThanBeginTime
                        ? Text(outputEndDateTime)
                        : !isEventEndTimeGreaterThanBeginTime
                        ? Text('Время окончания ' + outputEndDateTime
                        + ' должно быть больше времени начала')
                        : Text('Время окончания ' + outputEndDateTime
                        + ' должно быть не позже 24 часов после начала'),
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
                            selectedEndDateTime.millisecondsSinceEpoch
                                > selectedBeginDateTime.millisecondsSinceEpoch;

                        isEventDurationValidated =
                            (selectedEndDateTime.difference(selectedBeginDateTime)
                                .inMilliseconds) < (3600 * 24 * 1000);
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Тип мероприятия',
                    style: TextStyle(fontSize: 20, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 4.0),
                  DropdownButtonFormField(
                      value: selectedEventType,
                      items: eventTypes.map((String type){
                        return DropdownMenuItem(
                            value: type,
                            child: Text(type));
                      }).toList(),
                      onChanged: (String? newType){
                        setState(() {
                          selectedEventType = newType.toString();
                        });
                      }),
                  SizedBox(height: 20.0),
                  Text(
                    'Статус мероприятия',
                    style: TextStyle(fontSize: 20, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 4.0),
                  DropdownButtonFormField(
                      value: selectedEventStatus,
                      items: eventStatuses.map((String status){
                        return DropdownMenuItem(
                            value: status,
                            child: Text(status));
                      }).toList(),
                      onChanged: (String? newStatus){
                        setState(() {
                          selectedEventStatus = newStatus.toString();
                        });
                      }),
                  SizedBox(height: 30.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor : Colors.white,
                      shadowColor: Colors.cyan,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      minimumSize: Size(150, 50),
                    ),
                    onPressed: () async {
                      setState(() {
                        isCaptionValidated = !eventCaptionController.text.isEmpty;
                        isDescriptionValidated = !eventDescriptionController.text.isEmpty;

                        isEventEndTimeGreaterThanBeginTime =
                            selectedEndDateTime.millisecondsSinceEpoch
                                > selectedBeginDateTime.millisecondsSinceEpoch;

                        isEventDurationValidated =
                            (selectedEndDateTime.difference(
                                selectedBeginDateTime).inMilliseconds) < (3600 * 24 * 1000);

                        if (isCaptionValidated && isDescriptionValidated
                            && isEventDurationValidated && isEventEndTimeGreaterThanBeginTime){
                          editExistedEvent(context);
                        }
                      });
                    },
                    child: Text('Изменить текущее мероприятие'),
                  ),
              ],
          ),
        ))
    );
  }

  String selectedEventType = "None";
  String selectedEventStatus = "None";

  DateTime selectedBeginDateTime = DateTime.now();
  DateTime selectedEndDateTime = DateTime.now();

  String outputBeginDateTime = '';
  String outputEndDateTime = '';

  String existedCaption = '';
  String existedDescription = '';
}