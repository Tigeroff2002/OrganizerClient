import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:todo_calendar_client/EnumAliaser.dart';
import 'package:todo_calendar_client/content_widgets/system_alerts_list_page.dart';
import 'package:todo_calendar_client/content_widgets/system_issues_list_page.dart';
import 'package:todo_calendar_client/main_widgets/profile_page.dart';
import 'package:todo_calendar_client/models/requests/UserUpdateRoleRequest.dart';
import 'package:todo_calendar_client/models/responses/ShortUserInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';
import 'package:todo_calendar_client/shared_pref_cached_data.dart';
import 'dart:async';

import 'package:http/http.dart' as http;

import 'package:todo_calendar_client/main_widgets/user_page.dart';

import 'package:todo_calendar_client/GlobalEndpoints.dart';
import 'package:todo_calendar_client/models/requests/UserInfoRequestModel.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/GetResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithToken.dart';

class SystemAdminPageWidget extends StatefulWidget {

  final String userName;

  SystemAdminPageWidget({required this.userName});

  @override
  SystemAdminPageState createState() => SystemAdminPageState(userName: userName);
}

final headers = {'Content-Type': 'application/json'};

class SystemAdminPageState extends State<SystemAdminPageWidget> {
  String pictureUrl = "https://all-psd.ru/uploads/posts/2011-05/psd-web-user-icons.jpg";

  final String userName;
  String userRole = 'Admin';

  SystemAdminPageState({required this.userName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Страница системного администратора ' + userName),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePageWidget()),);
              },
            ),
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(6.0),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ваши дополнительные функции: ",
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.0),
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
                              builder: (context) => SystemIssuesListPageWidget()),);
                      },
                      child: Text('Список открытых проблемных запросов'),
                    ),
                    SizedBox(height: 20.0),
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
                              builder: (context) => SystemAlertsListPageWidget()),);
                      },
                      child: Text('Список системных алертов'),
                    ),
                    SizedBox(height: 30.0),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}
