import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_calendar_client/GlobalEndpoints.dart';
import 'package:todo_calendar_client/main_widgets/profile_page.dart';
import 'package:todo_calendar_client/content_widgets/user_info_map.dart';
import 'package:todo_calendar_client/main_widgets/home_page.dart';
import 'package:todo_calendar_client/main_widgets/login_page.dart';
import 'package:todo_calendar_client/main_widgets/register_page.dart';
import 'package:todo_calendar_client/main_widgets/user_page.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/HostModel.dart';
import 'package:todo_calendar_client/shared_pref_cached_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MySharedPreferences sharedPreferences = new MySharedPreferences();

  var existedData = await sharedPreferences.getDataIfNotExpired();

  if (existedData == null){
    var currentUri = GlobalEndpoints().mobileUri;

    var hostModel = new HostModel(currentHost: currentUri);

    var json = hostModel.toJson();

    await sharedPreferences.saveDataWithExpiration(jsonEncode(json),  const Duration(days: 7));
  }

  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAwpDtJyT2X9t-6gUpomwK37PPacHM6tFY",
        appId: "1:715256445207:android:3e76c820f3192f75045f52",
        messagingSenderId: "715256445207",
        projectId: "todocalendar-411917",)
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        '/session/profile_page': (context) => ProfilePageWidget()
      },
    );
  }
}


