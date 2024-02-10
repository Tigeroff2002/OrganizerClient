import 'package:flutter/material.dart';
import 'package:todo_calendar_client/profile_page.dart';
import 'package:todo_calendar_client/user_info_map.dart';
import 'package:todo_calendar_client/home_page.dart';
import 'package:todo_calendar_client/api_requests.dart';
import 'package:todo_calendar_client/login_page.dart';
import 'package:todo_calendar_client/register_page.dart';
import 'package:todo_calendar_client/user_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Многозадачный календарь',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/session/user_page': (context) => UserPage(),
        '/session/events_page': (context) => UserInfoMapPage(),
        '/session/additional_page': (context) => AdditionalPageWidget()
      },
    );
  }
}


