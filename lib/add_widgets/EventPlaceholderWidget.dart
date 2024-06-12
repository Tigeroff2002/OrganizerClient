import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/add_widgets/GroupPlaceholderWidget.dart';
import 'package:todo_calendar_client/content_widgets/single_content_widgets/SingleEventPageWidget.dart';
import 'package:todo_calendar_client/main_widgets/user_page.dart';
import 'package:todo_calendar_client/models/requests/UserInfoRequestModel.dart';
import 'package:todo_calendar_client/models/requests/users_list_requests/AllGroupUsersRequestModel.dart';
import 'package:todo_calendar_client/models/responses/GroupInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/ShortUserInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/GetResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithId.dart';
import 'package:todo_calendar_client/shared_pref_cached_data.dart';
import 'dart:convert';
import 'package:todo_calendar_client/models/requests/AddNewEventModel.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';
import '../GlobalEndpoints.dart';
import '../models/responses/additional_responces/ResponseWithToken.dart';

class EventPlaceholderWidget extends StatefulWidget {
  final Color color;
  final String text;
  final int index;

  EventPlaceholderWidget(
      {required this.color, required this.text, required this.index});

  @override
  EventPlaceholderState createState() {
    return new EventPlaceholderState(
        color: color, text: text, index: index, isPageJustLoaded: true);
  }
}

class EventPlaceholderState extends State<EventPlaceholderWidget> {
  final Color color;
  final String text;
  final int index;

  bool isPageJustLoaded;

  bool isBeginTimeChanged = false;
  bool isEndTimeChanged = false;

  late String token;

  bool isCaptionValidated = true;
  bool isDescriptionValidated = true;

  bool isEventEndTimeGreaterThanBeginTime = true;
  bool isEventDurationValidated = true;
  bool isEventStartsLaterThanNow = true;

  final TextEditingController eventCaptionController = TextEditingController();
  final TextEditingController eventDescriptionController =
      TextEditingController();

  @override
  void dispose() {
    eventCaptionController.dispose();
    eventDescriptionController.dispose();
    super.dispose();
  }

  EventPlaceholderState(
      {required this.color,
      required this.text,
      required this.index,
      required this.isPageJustLoaded});

  bool isServerDataLoaded = false;

  int currentUserId = -1;

  int currentGroupId = -1;
  String currentGroupName = "";

  @override
  void initState() {
    setState(() {
      isServerDataLoaded = false;
    });

    getGroupUsers(context).then((_) {
      isServerDataLoaded = true;
    });
  }

  int createEventId = -1;

  String currentHost = GlobalEndpoints().mobileUri;

  final headers = {'Content-Type': 'application/json'};

  List<GroupInfoResponse> groupsList = [];

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

      setState(() {
        currentUserId = cacheContent.userId;
      });

      var token = cacheContent.firebaseToken.toString();

      var model = new UserInfoRequestModel(userId: currentUserId, token: token);
      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = currentHost;

      var requestString = '/users/get_info';

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
          var userGroups = data['user_groups'];

          var fetchedGroups = List<GroupInfoResponse>.from(
              userGroups.map((data) => GroupInfoResponse.fromJson(data)));

          setState(() {
            groupsList = fetchedGroups;
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

  List<ShortUserInfoResponse> users = [];

  Future<void> getGroupUsers(BuildContext context) async {
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

      getUserInfo().then((_){
      if (groupsList.isEmpty){
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Ошибка!'),
              content: Text('Вы должны состоять хотя бы в одной группе'),
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

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => 
            GroupPlaceholderWidget( 
              color: color,
              text: text,
              index: 1)),);   
      }
      else {
        setState(() {
          currentGroupId = groupsList.first.groupId;
          currentGroupName = groupsList.first.groupName;         
        });
      }

      var model = 
        new AllGroupUsersRequestModel(
          userId: userId, 
          token: token,
          groupId: currentGroupId);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var requestString = '/users/get_group_users';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentHost + currentPort + requestString);

      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode(requestMap);

      try {
        http.post(url, headers: headers, body: body).then((response){
        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          var responseContent = GetResponse.fromJson(jsonData);

          if (responseContent.result) {
            var userRequestedInfo = responseContent.requestedInfo.toString();

            var data = jsonDecode(userRequestedInfo);
            var usersList = data['users'];

            var allUsers = List<ShortUserInfoResponse>.from(
                usersList.map((e) => ShortUserInfoResponse.fromJson(e)));

            setState(() {
              users = allUsers
                  .where((element) => element.userId != currentUserId)
                  .toList();
              usersCount = users.length;

              var list = choosedIndexes.length == 0
                  ? List<(int, bool)>.from(users.map((e) => (e.userId, false)))
                      .toList()
                  : List<(int, bool)>.from(users.map((e) =>
                      choosedIndexes.containsKey(e.userId) &&
                              !choosedIndexes.values
                                  .where((isChoosed) => isChoosed)
                                  .isEmpty
                          ? (e.userId, true)
                          : (e.userId, false))).toList();

              choosedIndexes = Map<int, bool>.fromIterable(list, key: (m) {
                var key = m as (int, bool);
                return key.$1;
              }, value: (m) {
                var value = m as (int, bool);
                return value.$2;
              });

              isServerDataLoaded = true;
            });
          }
        }
        });
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
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка!'),
          content: Text('Создание нового события не произошло!'),
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

  int usersCount = 0;
  Map<int, bool> choosedIndexes = {};

  Future<void> addNewEvent(BuildContext context) async {
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

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      setState(() {
        currentHost = cacheContent.currentHost;
        currentUserId = cacheContent.userId;
      });

      var userId = cacheContent.userId;
      var token = cacheContent.firebaseToken.toString();

      List<int> participants = [];

      participants.add(currentUserId);

      for (int key in choosedIndexes.keys) {
        var value = choosedIndexes[key];
        if (value != null) {
          if (value) {
            participants.add(key);
          }
        }
      }

      if (participants.isEmpty) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Ошибка!'),
            content: Text('Вы не выбрали пользоватателей группы'),
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

      var model = new AddNewEventModel(
          userId: (userId),
          token: token,
          caption: caption,
          description: description,
          start: scheduledStart,
          duration: duration,
          eventType: selectedEventType,
          eventStatus: selectedEventStatus,
          groupId: currentGroupId,
          guestIds: participants);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var requestString = '/events/schedule_new';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentHost + currentPort + requestString);

      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode(requestMap);

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          var responseContent = ResponseWithId.fromJson(jsonData);

          setState(() {
            createEventId = responseContent.id;
          });

          if (responseContent.outInfo != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SingleEventPageWidget(eventId: createEventId)));
                },
                child: Text(
                  'Перейти на страницу нового события с id = ' +
                      createEventId.toString(),
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
              ),
            ));
          }
        }

        eventCaptionController.clear();
        eventDescriptionController.clear();
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка!'),
          content: Text('Создание нового мероприятия не произошло!'),
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
                'Страничка создания нового мероприятия',
                style: TextStyle(fontSize: 16, color: Colors.deepPurple),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UserPage()),
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
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple),
                      ),
                      SizedBox(height: 30.0),
                      SizedBox(height: 16.0),
                      TextField(
                        controller: eventCaptionController,
                        style:
                            TextStyle(fontSize: 16, color: Colors.deepPurple),
                        decoration: InputDecoration(
                            labelText: 'Наименование мероприятия:',
                            labelStyle: TextStyle(
                                color: Colors.deepPurple, fontSize: 16),
                            errorText: !isCaptionValidated
                                ? 'Название мероприятия не может быть пустым'
                                : null),
                      ),
                      SizedBox(height: 12.0),
                      TextFormField(
                        style:
                            TextStyle(fontSize: 16, color: Colors.deepPurple),
                        controller: eventDescriptionController,
                        maxLines: null,
                        decoration: InputDecoration(
                            labelText: 'Описание меропрития:',
                            labelStyle: TextStyle(
                                color: Colors.deepPurple, fontSize: 16),
                            errorText: !isDescriptionValidated
                                ? 'Описание мероприятия не может быть пустым'
                                : null),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Время начала мероприятия',
                        style:
                            TextStyle(fontSize: 16, color: Colors.deepPurple),
                      ),
                      SizedBox(height: 12.0),
                      ElevatedButton(
                        child: Text(
                          outputBeginDateTime,
                          style:
                              TextStyle(fontSize: 16, color: Colors.deepPurple),
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
                                selectedEndDateTime.millisecondsSinceEpoch >
                                    selectedBeginDateTime
                                        .millisecondsSinceEpoch;

                            isEventDurationValidated = (selectedEndDateTime
                                    .difference(selectedBeginDateTime)
                                    .inMilliseconds) <
                                (3600 * 24 * 1000);

                            isEventStartsLaterThanNow = selectedBeginDateTime
                                    .difference(DateTime.now())
                                    .inMinutes >
                                0;
                          });
                        },
                      ),
                      SizedBox(height: 24.0),
                      Text(
                        'Время окончания мероприятия',
                        style:
                            TextStyle(fontSize: 16, color: Colors.deepPurple),
                      ),
                      SizedBox(height: 12.0),
                      TextButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEventDurationValidated &&
                                  isEventEndTimeGreaterThanBeginTime &&
                                  isEventStartsLaterThanNow
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
                                isEventEndTimeGreaterThanBeginTime &&
                                isEventStartsLaterThanNow
                            ? Text(outputEndDateTime)
                            : !isEventStartsLaterThanNow
                                ? Text('Время начала ' +
                                    outputBeginDateTime +
                                    ' должно быть больше текущего времени')
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
                            outputBeginDateTime = '${selectedEndDateTime.year}'
                                '/${selectedEndDateTime.month}'
                                '/${selectedEndDateTime.day}'
                                ' ${selectedEndDateTime.hour}'
                                ':${selectedEndDateTime.minute}';

                            isEventEndTimeGreaterThanBeginTime =
                                selectedEndDateTime.millisecondsSinceEpoch >
                                    selectedBeginDateTime
                                        .millisecondsSinceEpoch;

                            isEventDurationValidated = (selectedEndDateTime
                                    .difference(selectedBeginDateTime)
                                    .inMilliseconds) <
                                (3600 * 24 * 1000);

                            isEventStartsLaterThanNow = selectedBeginDateTime
                                    .difference(DateTime.now())
                                    .inMinutes >
                                0;
                          });
                        },
                      ),
                      SizedBox(height: 24.0),
                      Text(
                        'Тип мероприятия',
                        style:
                            TextStyle(fontSize: 16, color: Colors.deepPurple),
                      ),
                      SizedBox(height: 4.0),
                      DropdownButtonFormField(
                          value: selectedEventType,
                          style:
                              TextStyle(fontSize: 16, color: Colors.deepPurple),
                          decoration: InputDecoration(
                              labelStyle: TextStyle(
                                  fontSize: 16, color: Colors.deepPurple)),
                          items: eventTypes.map((String type) {
                            return DropdownMenuItem(
                                value: type, child: Text(type));
                          }).toList(),
                          onChanged: (String? newType) {
                            setState(() {
                              selectedEventType = newType.toString();
                            });
                          }),
                      SizedBox(height: 6.0),
                      Text(
                        'Мероприятие относится к вашей основной группе ' + currentGroupName,
                        style:
                            TextStyle(fontSize: 16, color: Colors.deepOrange),
                      ),
                      SizedBox(height: 6.0),
                      selectedEventType == 'Personal'
                          ? Text('Мероприятие рассчитано только для вас',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.deepOrange))
                          : Text('Доступен выбор участников группы',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.deepOrange)),
                      SizedBox(height: 20.0),
                      Text(
                        'Статус мероприятия',
                        style:
                            TextStyle(fontSize: 16, color: Colors.deepPurple),
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
                      SizedBox(height: 16.0),
                      selectedEventType != 'Personal'
                      ? choosedIndexes.values
                                  .where((element) => element)
                                  .length ==
                              0
                          ? Text(
                              'Вы не добавили участников мероприятия (кроме себя)',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.deepOrange))
                          : Text(
                              'Вы добавили ' +
                                  choosedIndexes.values
                                      .where((element) => element)
                                      .length
                                      .toString() +
                                  ' участников',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.deepPurple))
                      : SizedBox(height: 0.0,),
                      SizedBox(height: 2.0),
                      selectedEventType != 'Personal'
                      ? Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: usersCount,
                          itemBuilder: (BuildContext context, int index) {
                            return Row(
                              children: [
                                Text(users[index].userName,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.deepPurple)),
                                Checkbox(
                                    value: choosedIndexes[users[index].userId],
                                    onChanged: (value) {
                                      setState(() {
                                        choosedIndexes[users[index].userId] =
                                            !choosedIndexes[
                                                users[index].userId]!;
                                      });
                                    })
                              ],
                            );
                          },
                        ),
                      )
                      : SizedBox(height: 0.0,),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isCaptionValidated =
                                !eventCaptionController.text.isEmpty;
                            isDescriptionValidated =
                                !eventDescriptionController.text.isEmpty;

                            isEventEndTimeGreaterThanBeginTime =
                                selectedEndDateTime.millisecondsSinceEpoch >
                                    selectedBeginDateTime
                                        .millisecondsSinceEpoch;

                            isEventDurationValidated = (selectedEndDateTime
                                    .difference(selectedBeginDateTime)
                                    .inMilliseconds) <
                                (3600 * 24 * 1000);

                            isEventStartsLaterThanNow = selectedBeginDateTime
                                    .difference(DateTime.now())
                                    .inMinutes >
                                0;

                            if (isCaptionValidated &&
                                isDescriptionValidated &&
                                isEventDurationValidated &&
                                isEventEndTimeGreaterThanBeginTime &&
                                isEventStartsLaterThanNow) {
                              addNewEvent(context);
                            }
                          });
                        },
                        child: Text(
                          'Создать новое мероприятие',
                          style:
                              TextStyle(fontSize: 16, color: Colors.deepPurple),
                        ),
                      ),
                    ],
                  ),
                ))));
  }

  String selectedEventType = "None";
  String selectedEventStatus = "None";

  DateTime selectedBeginDateTime = DateTime.now();
  DateTime selectedEndDateTime = DateTime.now();

  String outputBeginDateTime = '';
  String outputEndDateTime = '';
}
