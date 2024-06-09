import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/GlobalEndpoints.dart';
import 'package:todo_calendar_client/main_widgets/authorization_page.dart';
import 'package:todo_calendar_client/models/requests/UserLoginModel.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/HostModel.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/RawResponseWithTokenAndName.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithToken.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithTokenAndName.dart';
import 'package:todo_calendar_client/shared_pref_cached_data.dart';
import 'package:todo_calendar_client/main_widgets/user_page.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() {
    return new LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isEmailValidated = true;
  bool isPasswordValidated = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login(BuildContext context) async {
    String email = emailController.text;
    String password = passwordController.text;

    FirebaseMessaging.instance.getToken().then((value) {
      setState(() {
        String token = value.toString();

        var model = new UserLoginModel(
            email: email, password: password, firebaseToken: token);

        var requestMap = model.toJson();

        var uris = GlobalEndpoints();

        bool isMobile = Theme.of(context).platform == TargetPlatform.android;

        var mySharedPreferences = new MySharedPreferences();

        mySharedPreferences.getDataIfNotExpired().then((cachedData) {
          if (cachedData != null) {
            var json = jsonDecode(cachedData.toString());
            var cacheContent = HostModel.fromJson(json);

            var currentUri = cacheContent.currentHost.toString();

            var requestString = '/users/login';

            var currentPort =
                isMobile ? uris.currentMobilePort : uris.currentWebPort;

            final url = Uri.parse(currentUri + currentPort + requestString);

            final headers = {'Content-Type': 'application/json'};

            final body = jsonEncode(requestMap);

            try {
              http.post(url, headers: headers, body: body).then((response) {
                if (response.statusCode == 200) {
                  MySharedPreferences mySharedPreferences =
                      new MySharedPreferences();

                  mySharedPreferences.getDataIfNotExpired().then((data) {
                    var json = jsonDecode(data.toString());

                    var currentUri = json['current_host'];

                    mySharedPreferences.clearData().then((_) {
                      var loginData = RawResponseWithTokenAndName.fromJson(
                          jsonDecode(response.body));

                      var structuredData = new ResponseWithTokenAndName(
                          result: loginData.result,
                          userId: loginData.userId,
                          token: loginData.token,
                          firebaseToken: loginData.firebaseToken,
                          currentHost: currentUri,
                          userName: loginData.userName);

                      var dataToBeCached = jsonEncode(structuredData.toJson());

                      mySharedPreferences
                          .saveDataWithExpiration(
                              dataToBeCached, const Duration(days: 7))
                          .then((_) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserPage()));

                        emailController.clear();
                        passwordController.clear();
                      });
                    });
                  });
                } else if (response.statusCode == 400) {
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Ошибка!'),
                      content: Text('Вы ввели неверную почту или пароль!'
                          ' Удостоверьтесь, что аккаунт существует'),
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
                } else {
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Ошибка!'),
                      content: Text('Произошла ошибка на сервере'),
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

                passwordController.clear();
              });
            } catch (e) {
              if (e is TimeoutException) {
                //treat TimeoutException
                print("Timeout exception: ${e.toString()}");
              } else
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
      });
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
            'Вход в ваш аккаунт',
            style: TextStyle(fontSize: 16, color: Colors.deepPurple),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthorizationPage()),
              );
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                decoration: InputDecoration(
                    labelText: 'Электронная почта: ',
                    labelStyle:
                        TextStyle(fontSize: 16, color: Colors.deepPurple),
                    errorText: !isEmailValidated
                        ? 'Почта не может быть пустой'
                        : null),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'Пароль: ',
                    labelStyle:
                        TextStyle(fontSize: 16, color: Colors.deepPurple),
                    errorText: !isPasswordValidated
                        ? 'Пароль не может быть пустым'
                        : null),
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isEmailValidated = !emailController.text.isEmpty;
                    isPasswordValidated = !passwordController.text.isEmpty;

                    if (isEmailValidated && isPasswordValidated) {
                      login(context);
                    }
                  });
                },
                child: Text(
                  'Войти в аккаунт',
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
