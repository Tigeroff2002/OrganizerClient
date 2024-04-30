import 'package:flutter/material.dart';
import 'package:todo_calendar_client/content_widgets/events_list_page.dart';
import 'package:todo_calendar_client/content_widgets/groups_list_page.dart';
import 'package:todo_calendar_client/content_widgets/issues_list_page.dart';
import 'package:todo_calendar_client/content_widgets/snapshots_list_page.dart';
import 'package:todo_calendar_client/content_widgets/tasks_list_page.dart';
import 'package:todo_calendar_client/main_widgets/map_info_dart.dart';
import 'package:todo_calendar_client/main_widgets/personal_account.dart';

class UserInfoMapPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.deepPurple,
      ),
      home: HomeMap(),
    );
  }
}

class HomeMap extends StatefulWidget {

  @override
  State<HomeMap> createState() => _HomeState();
}

class _HomeState extends State<HomeMap> {
  int _currentIndex = 0;

  @override
  void initState(){
    super.initState();
  }

  final List<Widget> _children = [
    MapInfoWidget(
        color: Colors.red,
        text: 'Страница деятельности пользователя',
        index: 0
    ),
    EventsListPageWidget(),
    GroupsListPageWidget(),
    TasksListPageWidget(),
    IssuesListPageWidget(),
    SnapshotsListPageWidget(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
      home: Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        backgroundColor: Colors.teal,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.greenAccent,
        iconSize: 40.0,
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.toc),
              label: 'Главная страница',
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_alarms),
            label: 'Мои мероприятия',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            label: 'Мои группы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            label: 'Мои задачи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call_outlined),
            label: 'Мои запросы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.comment_rounded),
            label: 'Мои личные снапшоты',
          ),
        ],
      ),
    ));
  }
}