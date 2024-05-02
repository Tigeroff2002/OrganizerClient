import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_calendar_client/main_widgets/user_page.dart';
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

class MapInfoWidget extends StatefulWidget{

  final Color color;
  final String text;
  final int index;

  MapInfoWidget(
      {
        required this.color,
        required this.text,
        required this.index
      });

  @override
  MapInfoState createState(){
    return new MapInfoState(color: color, text: text, index: index);
  }
}

class MapInfoState extends State<MapInfoWidget> {

  final Color color;
  final String text;
  final int index;

  MapInfoState(
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

  bool isCacheDataLoaded = false;

  Future<void> getUserNameFromCache() async {
    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    setState(() {
      isCacheDataLoaded = false;
    });

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithTokenAndName.fromJson(json);

      setState(() {
        currentUserName = cacheContent.userName.toString();
        isCacheDataLoaded = true;
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
          title: Text('Информация о вашей деятельности',
             style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
            centerTitle: true
        ),
        body: Center(
          child: Padding(
              padding: EdgeInsets.all(6.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: !isCacheDataLoaded
                  ? [Center(
                      child: SpinKitCircle(
                        size: 100,
                        color: Colors.deepPurple, 
                        duration: Durations.medium1,) )]
                  : [
                    Text(
                      "Еще раз, приветствуем вас, " + currentUserName,
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserPage()),);
                      },
                      child: Text('Вернуться на главную', 
                        style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
                    ),
                    SizedBox(height: 30.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePageWidget()),);
                      },
                      child: Text('Профиль пользователя',
                        style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
                    ),
                    SizedBox(height: 36.0),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          logout(context);
                        });
                      },
                      child: Text('Выйти из аккаунта', 
                        style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
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
          var sharedPreferences = new MySharedPreferences();

          var hostModel = new HostModel(currentHost: currentUri);

          var json = hostModel.toJson();

          await sharedPreferences.clearData();

          await sharedPreferences.saveDataWithExpiration(jsonEncode(json),  const Duration(days: 7));

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