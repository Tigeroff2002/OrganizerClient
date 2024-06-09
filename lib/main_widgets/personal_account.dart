import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_calendar_client/models/requests/UserLogoutModel.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/HostModel.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithTokenAndName.dart';
import 'package:todo_calendar_client/shared_pref_cached_data.dart';
import 'package:todo_calendar_client/content_widgets/user_info_map.dart';

import 'package:todo_calendar_client/GlobalEndpoints.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/GetResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithToken.dart';
import 'profile_page.dart';
import 'home_page.dart';

class PersonalAccountWidget extends StatefulWidget {
  final Color color;
  final String text;
  final int index;

  PersonalAccountWidget(
      {required this.color, required this.text, required this.index});

  @override
  PersonalAccountState createState() {
    return new PersonalAccountState(color: color, text: text, index: index);
  }
}

class PersonalAccountState extends State<PersonalAccountWidget> {
  final Color color;
  final String text;
  final int index;

  String currentHost = GlobalEndpoints().mobileUri;

  PersonalAccountState(
      {required this.color, required this.text, required this.index});

  @override
  void initState() {
    super.initState();
    getUserNameFromCache();
  }

  bool isCacheDataLoaded = false;

  Future<void> getUserNameFromCache() async {
    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    setState(() {
      isCacheDataLoaded = false;
    });

    mySharedPreferences.getDataIfNotExpired().then((cachedData) {
      if (cachedData != null) {
        var json = jsonDecode(cachedData.toString());
        var cacheContent = ResponseWithTokenAndName.fromJson(json);

        setState(() {
          currentUserName = cacheContent.userName.toString();
          currentHost = cacheContent.currentHost;
          isCacheDataLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
        home: Scaffold(
            appBar: AppBar(
                title: Text(
                  'Главная страница приложения',
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
                centerTitle: true),
            body: Center(
              child: Padding(
                  padding: EdgeInsets.all(6.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: !isCacheDataLoaded
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
                                "Добро пожаловать, " + currentUserName,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 30.0),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            UserInfoMapPage()),
                                  );
                                },
                                child: Text(
                                  'Информация о вашей деятельности',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.deepPurple),
                                ),
                              ),
                              SizedBox(height: 30.0),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProfilePageWidget()),
                                  );
                                },
                                child: Text(
                                  'Профиль пользователя',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.deepPurple),
                                ),
                              ),
                              SizedBox(height: 36.0),
                              ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomePage()),
                                    );
                                    logout(context);

                                    var mySharedPreferences =
                                        new MySharedPreferences();

                                    mySharedPreferences.clearData();
                                  });
                                },
                                child: Text(
                                  'Выйти из аккаунта',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.deepPurple),
                                ),
                              ),
                            ],
                    ),
                  )),
            )));
  }

  Future<void> logout(BuildContext context) async {
    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      setState(() {
        currentHost = cacheContent.currentHost;
      });

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();
      var firebaseToken = cacheContent.firebaseToken.toString();

      var model = new UserLogoutModel(
          userId: userId, token: token, firebaseToken: firebaseToken);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var requestString = '/users/logout';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentHost + currentPort + requestString);

      final body = jsonEncode(requestMap);

      try {
        final response = await http.post(url, headers: headers, body: body);

        var jsonData = jsonDecode(response.body);
        var responseContent = GetResponse.fromJson(jsonData);

        if (responseContent.result) {
          var sharedPreferences = new MySharedPreferences();

          var hostModel = new HostModel(currentHost: currentHost);

          var json = hostModel.toJson();

          await sharedPreferences.clearData();

          await sharedPreferences.saveDataWithExpiration(
              jsonEncode(json), const Duration(days: 7));
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

  String currentUserName = "None user";
}
