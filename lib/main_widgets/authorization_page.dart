import 'package:flutter/material.dart';
import 'package:todo_calendar_client/main_widgets/home_page.dart';
import 'package:todo_calendar_client/main_widgets/login_page.dart';
import 'package:todo_calendar_client/main_widgets/register_page.dart';

class AuthorizationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
      home: Scaffold(
        appBar: AppBar(
            title: Text('Календарь Tigeroff'),
            centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage()),);
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('Авторизация', style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text('Регистрация', style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}