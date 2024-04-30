import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_calendar_client/models/requests/UserLogoutModel.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithTokenAndName.dart';
import 'package:todo_calendar_client/shared_pref_cached_data.dart';
import 'package:todo_calendar_client/content_widgets/user_info_map.dart';

import 'package:todo_calendar_client/GlobalEndpoints.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/GetResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithToken.dart';
import 'profile_page.dart';
import 'home_page.dart';

class PersonalAccount extends StatefulWidget{

  final Color color;
  final String text;
  final int index;

  PersonalAccount(
      {
        required this.color,
        required this.text,
        required this.index
      });

  @override
  PersonalAccountState createState(){
    return new PersonalAccountState(color: color, text: text, index: index);
  }
}


class PersonalAccountState extends State<PersonalAccount> {

  final Color color;
  final String text;
  final int index;

  PersonalAccountState(
      {
        required this.color,
        required this.text,
        required this.index
      });

  @override
  void initState() {
    super.initState();
    getUserNameFromCache();
  }

  Future<void> getUserNameFromCache() async {
    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithTokenAndName.fromJson(json);

      setState(() {
        currentUserName = cacheContent.userName.toString();
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
          title: Text('Главная страница приложения'),
            centerTitle: true
        ),
        body: Center(
          child: Padding(
              padding: EdgeInsets.all(6.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Добро пожаловать, " + currentUserName,
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor : Colors.white,
                        shadowColor: Colors.greenAccent,
                        elevation: 3,
                        minimumSize: Size(200, 60),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserInfoMapPage()),);
                      },
                      child: Text('Информация о вашей деятельности'),
                    ),
                    SizedBox(height: 30.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor : Colors.white,
                        shadowColor: Colors.greenAccent,
                        elevation: 3,
                        minimumSize: Size(200, 60),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePageWidget()),);
                      },
                      child: Text('Профиль пользователя'),
                    ),
                    SizedBox(height: 36.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor : Colors.white,
                        shadowColor: Colors.greenAccent,
                        elevation: 3,
                        minimumSize: Size(200, 60),
                      ),
                      onPressed: () async {
                        setState(() {
                          logout(context);
                        });
                      },
                      child: Text('Выйти из аккаунта'),
                    ),
                  ],
                ),
              )
          ),
        )
      )
    );
  }

  Future<void> logout(BuildContext context) async {

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();
      var firebaseToken = cacheContent.firebaseToken.toString();

      var model = new UserLogoutModel(
          userId: userId,
          token: token,
          firebaseToken: firebaseToken);

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/users/logout';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentUri + currentPort + requestString);

      final body = jsonEncode(requestMap);

      try {
        final response = await http.post(url, headers: headers, body: body);

        var jsonData = jsonDecode(response.body);
        var responseContent = GetResponse.fromJson(jsonData);

        if (responseContent.result) {
          await mySharedPreferences.clearData();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage()),);
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
      setState(() {
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
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
  
  String currentUserName = "None user";
}