import 'package:flutter/material.dart';
import 'package:todo_calendar_client/add_widgets/EventPlaceholderWidget.dart';
import 'package:todo_calendar_client/add_widgets/GroupPlaceholderWidget.dart';
import 'package:todo_calendar_client/add_widgets/IssuePlaceholderWidget.dart';
import 'package:todo_calendar_client/add_widgets/TaskPlaceholderWidget.dart';
import 'package:todo_calendar_client/add_widgets/SnapshotPlaceholderWidget.dart';
import 'package:todo_calendar_client/personal_account.dart';

class UserPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  @override
  void initState(){
    super.initState();
  }

  final List<Widget> _children = [
    PersonalAccount(
        color: Colors.red,
        text: 'Главная страница пользователя',
        index: 0
    ),

    EventPlaceholderWidget(
        color: Colors.green,
        text: 'Страница создания мероприятия',
        index: 1),

    GroupPlaceholderWidget(
        color: Colors.blueAccent,
        text: 'Страница создания новой группы',
        index: 2),

    TaskPlaceholderWidget(
        color: Colors.lime,
        text: 'Страница создания новой задачи',
        index: 3),

    SnapshotPlaceholderWidget(
        color: Colors.deepPurpleAccent,
        text: 'Страница создания нового снапшота',
        index: 4),

    IssuePlaceholderWidget(
        color: Colors.deepOrange,
        text: 'Страница создания нового запроса',
        index: 5)
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
      home: Scaffold(
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          backgroundColor: Colors.teal,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.greenAccent,
          currentIndex: _currentIndex,
          iconSize: 40.0,
          onTap: onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.toc),
              label: 'Главная страница',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_alarm),
              label: 'Новое мероприятие',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_business_outlined),
              label: 'Новая группа',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_task),
              label: 'Новая задача',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_comment_rounded),
              label: 'Новый снапшот',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_ic_call_outlined),
              label: 'Новый запрос для администрации',
            ),
          ],
        ),
      ),
    );
  }
}