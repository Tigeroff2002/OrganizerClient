import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_calendar_client/main_widgets/authorization_page.dart';
import 'package:todo_calendar_client/main_widgets/register_page.dart';
import 'package:todo_calendar_client/models/requests/UserEmailConfirmationModel.dart';
import 'package:todo_calendar_client/models/requests/UserRegisterModel.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/HostModel.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/HostModelConfirmation.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/RawResponseWithTokenAndName.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/RegistrationResponse.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithToken.dart';
import 'dart:convert';
import 'package:todo_calendar_client/main_widgets/user_page.dart';
import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithTokenAndName.dart';
import 'package:todo_calendar_client/shared_pref_cached_data.dart';

import 'package:todo_calendar_client/GlobalEndpoints.dart';

class EmailConfirmationPage extends StatefulWidget {

  final HostModelConfirmation cachedData;

  EmailConfirmationPage({required this.cachedData});

  @override
  EmailConfirmationPageState createState(){
    return new EmailConfirmationPageState(cachedData: cachedData);
  }
}

class EmailConfirmationPageState extends State<EmailConfirmationPage> {

  final HostModelConfirmation cachedData;

  EmailConfirmationPageState({required this.cachedData});

  final TextEditingController codeController = TextEditingController();

  bool isCodeValidated = true;

  int currentSecondsRemaining = 120;

  void showExpiredDialog(BuildContext context){
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Время истекло!'),
                      content: Text(
                          'Время подтверждения истекло'),
                      actions: [
                        TextButton(
                          onPressed: () {
                  Navigator.pushReplacement(
                    context,
                      MaterialPageRoute(builder: (context)
                        => EmailConfirmationPage(cachedData: cachedData,)));
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
  }

  @override
  void initState(){
    currentSecondsRemaining = 120;

    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentSecondsRemaining--;

        checkIfEmailConfirmationExpired(cachedData.email).then((value) => {
          if (value){
            showExpiredDialog(context)
          }
        });
      });
     });
  }

  @override
  void dispose() {
    codeController.clear();
    super.dispose();
  }

  Future<http.Response> confirmCode(BuildContext context) async {

    var code = codeController.text;

    var email = cachedData.email.toString();

    var model = new UserEmailConfirmationModel(email: email, code: code);

    var uris = GlobalEndpoints();

    bool isMobile = Theme.of(context).platform == TargetPlatform.android;

    var requestString = '/users/confirm';

    var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

    var currentUri = cachedData.currentHost;

    final url = Uri.parse(currentUri + currentPort + requestString);

    final headers = {'Content-Type': 'application/json'};

    var requestMap = model.toJson();

    final body = jsonEncode(requestMap);  

    try {
      http.post(url, headers: headers, body : body).then((response){

      if (response.statusCode == 200){

        var jsonData = jsonDecode(response.body);

        var responseContent = RegistrationResponse.fromJson(jsonData);

        var registerCase = responseContent.registrationCase;

        if (registerCase == 'ConfirmationExpired'){
          showExpiredDialog(context);
        }
        else if (registerCase == 'CodeNotEqualsConfirmation'){
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Код введен не верно!'),
                      content: Text(
                          'Код введен не верно, попробуйте снова'),
                      actions: [
                        TextButton(
                          onPressed: () {
                  Navigator.pushReplacement(
                    context,
                      MaterialPageRoute(builder: (context)
                        => EmailConfirmationPage(cachedData: cachedData,)));
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );          
        }
        else if (registerCase == 'ConfirmationSucceeded'){
          enableFinalOfRegistration(response).then((_) => {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context)
                => UserPage()))
          });
        }

        return response;
      }

      return null!;
    });
    }
    catch (e){
              if (e is TimeoutException) {
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
    finally{
      return null!;
    }
  }

  Future<bool> checkIfEmailConfirmationExpired(String email){
    var code = codeController.text;

    var email = cachedData.email.toString();

    var model = new UserEmailConfirmationModel(email: email, code: code);

    var uris = GlobalEndpoints();

    bool isMobile = Theme.of(context).platform == TargetPlatform.android;

    var requestString = '/users/check_if_time_expired';

    var currentPort = isMobile ? uris.currentMobilePort : uris.currentWebPort;

    var currentUri = cachedData.currentHost;

    final url = Uri.parse(currentUri + currentPort + requestString);

    final headers = {'Content-Type': 'application/json'};

    var requestMap = model.toJson();

    final body = jsonEncode(requestMap);  

    try {
      http.post(url, headers: headers, body : body).then((response){

      if (response.statusCode == 200){

        var jsonData = jsonDecode(response.body);

        var responseContent = Response.fromJson(jsonData);

        return responseContent.result;
      }

      return null!;
    });
    }
    catch (e){
              if (e is TimeoutException) {
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
    finally{
      return null!;
    }   
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(scaffoldBackgroundColor: Colors.cyanAccent),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Подтверждение почты', 
            style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => RegisterPage()),);
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Подтверждение почты ' + cachedData.email, 
                style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
              SizedBox(height: 12.0),
              Text('Осталось времени: ' + currentSecondsRemaining.toString() + ' секунд',
                style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
              SizedBox(height: 16.0),
              TextField(
                controller: codeController,
                style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                decoration: InputDecoration(
                    labelText: 'Код подтверждения: ',
                    labelStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurple
                    ),
                    errorText: !isCodeValidated
                        ? 'Код не может быть пустым'
                        : null
                ),
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isCodeValidated = !codeController.text.isEmpty;

                    if (isCodeValidated) {
                        confirmCode(context);
                    }
                  });
                },
                child: Text('Подтвердить код',
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> enableFinalOfRegistration(http.Response response){
                  MySharedPreferences mySharedPreferences = new MySharedPreferences();

                  mySharedPreferences.getDataIfNotExpired().then((data){

                  var json = jsonDecode(data.toString());

                  var currentUri = json['current_host'];

                  mySharedPreferences.clearData().then((_) {
                  var registerData = RawResponseWithTokenAndName.fromJson(jsonDecode(response.body));

                  var structuredData = 
                    new ResponseWithTokenAndName(
                      result: registerData.result,
                      userId: registerData.userId, 
                      token: registerData.token, 
                      firebaseToken: registerData.firebaseToken, 
                      currentHost: currentUri,
                      userName: registerData.userName);

                  var dataToBeCached = jsonEncode(structuredData.toJson());

                  mySharedPreferences.saveDataWithExpiration(
                    dataToBeCached, const Duration(days: 7)).then((_){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context)
                            => UserPage()));

                  codeController.clear();
                  });
                });
              });

    return null!;
  }
}