import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:todo_calendar_client/EnumAliaser.dart';
import 'package:todo_calendar_client/main_widgets/system_admin_page.dart';
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

class ProfilePageWidget extends StatefulWidget {

  @override
  ProfilePageState createState() => ProfilePageState();
}

final headers = {'Content-Type': 'application/json'};

class ProfilePageState extends State<ProfilePageWidget> {
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

  bool isServerDataLoaded = false;

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

      setState(() {
        isServerDataLoaded = false;
      });

      try {
        final response = await http.post(url, headers: headers, body: body);

        var jsonData = jsonDecode(response.body);
        var responseContent = GetResponse.fromJson(jsonData);

        if (responseContent.result) {
          var userRequestedInfo = responseContent.requestedInfo.toString();

          var data = jsonDecode(userRequestedInfo);

          setState(() {
            userName = data['user_name'].toString();
            userRole = data['user_role'].toString();
            isUserRole = userRole == 'User';
            accountCreationTime = data['account_creation'].toString();
            email = data['user_email'].toString();
            phoneNumber = data['phone_number'].toString();
            password = data['password'].toString();

            isServerDataLoaded = true;
          });
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

          setState(() {
            getUserInfo();
          });

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Профиль пользователя', 
              style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
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
                  children: 
                  !isServerDataLoaded
                  ? [Center(
                      child: SpinKitCircle(
                        size: 100,
                        color: Colors.deepPurple, 
                        duration: Durations.medium1,) )]
                  : [
                    Text(
                      'Данные о пользователе: ',
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Text(
                      'Имя пользователя: ',
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Text(
                      utf8.decode(utf8.encode(userName)),
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Роль пользователя: ',
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                      ),
                    ),
                    Text(
                        aliaser.GetAlias(
                            aliaser.getUserRoleEnumValue(userRole)),
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                        )
                    ),
                    SizedBox(height: 12.0),
                    !isUserRole
                      ? ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SystemAdminPageWidget(userName: userName)),);
                      },
                      child: Text('Функционал администратора', 
                        style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
                    )
                    : Text(
                      'Вам недоступен функционал администратора',
                      style: TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 16
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Image.network(pictureUrl, cacheWidth: 100, cacheHeight: 100,),
                    SizedBox(height: 12.0),
                    Text(
                      'Электронная почта: ',
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                      ),
                    ),
                    SizedBox(height: 6.0),
                    Text(
                      utf8.decode(utf8.encode(email)),
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Text(
                      'Номер телефона: ',
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                      ),
                    ),
                    SizedBox(height: 6.0),
                    Text(
                      utf8.decode(utf8.encode(phoneNumber)),
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Text(
                      'Пароль: ',
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                      ),
                    ),
                    SizedBox(height: 6.0),
                    Text(
                      isPasswordHidden
                        ? utf8.decode(utf8.encode(passwordHidden))
                        : utf8.decode(utf8.encode(password)),
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
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
                            ? Text('Показать пароль', 
                                style: TextStyle(fontSize: 16, color: Colors.deepPurple),)
                            : Text('Cкрыть пароль',
                                style: TextStyle(fontSize: 16, color: Colors.deepPurple),)),
                    SizedBox(height: 20.0),
                    Text(
                      'Дата создания учетной записи: ',
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Text(
                      utf8.decode(utf8.encode(accountCreationTime)),
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16
                      ),
                    ),
                    SizedBox(height: 16.0),
                    isUserRole
                    ? TextField(
                      controller: rootPasswordController,
                      style: TextStyle(fontSize: 16, color: Colors.deepPurple),
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
                    )
                    : SizedBox(height: 0.0),
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
                            ? Text('Запросить роль админа', 
                                style: TextStyle(fontSize: 16, color: Colors.deepPurple),)
                            : Text('Сбросить роль до пользователя',
                                style: TextStyle(fontSize: 16, color: Colors.deepPurple),)),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}
