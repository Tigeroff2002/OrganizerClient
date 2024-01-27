import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:todo_calendar_client/EnumAliaser.dart';
import 'package:todo_calendar_client/models/requests/UserUpdateRoleRequest.dart';
import 'package:todo_calendar_client/models/responses/ShortUserInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';
import 'package:todo_calendar_client/shared_pref_cached_data.dart';
import 'dart:async';

import 'package:http/http.dart' as http;

import 'package:todo_calendar_client/user_page.dart';

import 'GlobalEndpoints.dart';
import 'models/requests/UserInfoRequestModel.dart';
import 'models/responses/additional_responces/GetResponse.dart';
import 'models/responses/additional_responces/ResponseWithToken.dart';

class AdditionalPageWidget extends StatefulWidget {

  @override
  _AdditionalPageState createState() => _AdditionalPageState();
}

final headers = {'Content-Type': 'application/json'};

class _AdditionalPageState extends State<AdditionalPageWidget> {
  String pictureUrl = "https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg";

  String accountCreationTime = '';
  String userRole = 'User';
  String userName = '';
  String email = '';
  String phoneNumber = '';
  String password = '';
  String passwordHidden = '**********';

  bool isPasswordHidden = true;
  bool isUserRole = true;

  final TextEditingController rootPasswordController = TextEditingController();

  bool isRootPasswordValidated = true;

  final EnumAliaser aliaser = new EnumAliaser();

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {

    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null){
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();

      var model = new UserInfoRequestModel(userId: userId, token: token);
      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/users/get_info';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentUri + currentPort + requestString);

      final body = jsonEncode(requestMap);

      try {
        final response = await http.post(url, headers: headers, body: body);

        var jsonData = jsonDecode(response.body);
        var responseContent = GetResponse.fromJson(jsonData);

        if (responseContent.result) {
          var userRequestedInfo = responseContent.requestedInfo.toString();

          print(userRequestedInfo);
          var data = jsonDecode(userRequestedInfo);

          setState(() {
            userName = data['user_name'].toString();
            userRole = data['user_role'].toString();
            isUserRole = userRole == 'User';
            //accountCreationTime = data['account_creation'].toString();
            email = data['user_email'].toString();
            phoneNumber = data['phone_number'].toString();
            password = data['password'].toString();
          });
        }
      }
      catch (e) {
        if (e is SocketException) {
          //treat SocketException
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
        }
        else if (e is TimeoutException) {
          //treat TimeoutException
          print("Timeout exception: ${e.toString()}");
        }
        else
          print("Unhandled exception: ${e.toString()}");
      }
    }
    else {
      setState(() {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Ошибка!'),
            content:
            Text(
                'Произошла ошибка при получении'
                    ' информации о пользователе!'),
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

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Профиль пользователя'),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserPage()),);
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
                      'Данные о пользователе: ',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Text(
                      'Имя пользователя: ',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Text(
                      utf8.decode(utf8.encode(userName)),
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Роль пользователя: ',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                        aliaser.GetAlias(
                            aliaser.getUserRoleEnumValue(userRole)),
                        style: TextStyle(
                          color: Colors.white,
                        )
                    ),
                    SizedBox(height: 12.0),
                    Image.network(pictureUrl, scale: 0.01),
                    SizedBox(height: 12.0),
                    Text(
                      'Электронная почта: ',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 6.0),
                    Text(
                      utf8.decode(utf8.encode(email)),
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Text(
                      'Номер телефона: ',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 6.0),
                    Text(
                      utf8.decode(utf8.encode(phoneNumber)),
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Text(
                      'Пароль: ',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 6.0),
                    Text(
                      isPasswordHidden
                        ? utf8.decode(utf8.encode(passwordHidden))
                        : utf8.decode(utf8.encode(password)),
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 8.0),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isPasswordHidden = !isPasswordHidden;
                          });
                        },
                        child: isPasswordHidden
                            ? Text('Показать пароль')
                            : Text('Cкрыть пароль')),
                    SizedBox(height: 20.0),
                    Text(
                      'Дата создания учетной записи: ',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Text(
                      utf8.decode(utf8.encode(accountCreationTime)),
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Text(
                      'Запросить смену роли: ',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: rootPasswordController,
                      decoration: InputDecoration(
                          labelText: 'Рут пароль пользователя: ',
                          labelStyle: TextStyle(
                              fontSize: 16.0,
                              color: Colors.deepPurple
                          ),
                          errorText: !isRootPasswordValidated
                              ? 'Пароль рут пользователя не может быть пустым'
                              : null
                      ),
                    ),
                    SizedBox(height: 12.0),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isUserRole = userRole == 'User';
                            isRootPasswordValidated = !rootPasswordController.text.isEmpty;

                            if (isRootPasswordValidated){
                              updateUserRole(isUserRole);
                            }
                          });
                        },
                        child: isUserRole
                            ? Text('Запросить роль админа')
                            : Text('Сбросить роль до пользователя')),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }

  Future<void> updateUserRole(bool isUserRole) async
  {
    MySharedPreferences mySharedPreferences = new MySharedPreferences();

    var cachedData = await mySharedPreferences.getDataIfNotExpired();

    if (cachedData != null) {
      var json = jsonDecode(cachedData.toString());
      var cacheContent = ResponseWithToken.fromJson(json);

      var userId = cacheContent.userId;
      var token = cacheContent.token.toString();

      var requestedRole = isUserRole ? 'Admin' : 'User';

      var model = new UserUpdateRoleRequest(
          userId: userId,
          token: token,
          newRole: requestedRole,
          rootPassword: rootPasswordController.text.toString());

      var requestMap = model.toJson();

      var uris = GlobalEndpoints();

      bool isMobile = Theme.of(context).platform == TargetPlatform.android;

      var currentUri = isMobile ? uris.mobileUri : uris.webUri;

      var requestString = '/users/update_user_role';

      var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

      final url = Uri.parse(currentUri + currentPort + requestString);

      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode(requestMap);

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {

          var jsonData = jsonDecode(response.body);
          var responseContent = Response.fromJson(jsonData);

          if (responseContent.outInfo != null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(responseContent.outInfo.toString())
                )
            );
          }
        }

        rootPasswordController.clear();
      }
      catch (e) {
        if (e is SocketException) {
          //treat SocketException
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
        }
        else if (e is TimeoutException) {
          //treat TimeoutException
          print("Timeout exception: ${e.toString()}");
        }
        else
          print("Unhandled exception: ${e.toString()}");
      }
    }
    else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка!'),
          content: Text('Изменение роли текущего пользователя не удалось!'),
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
  }
}
