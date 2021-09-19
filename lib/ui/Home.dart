import 'dart:math';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:notification/database/database_helper.dart';
import 'package:notification/ui/bazarList.dart';
import 'package:notification/ui/emptyDialogue.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CustomDialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'map_page.dart';

const EVENTS_KEY = "fetch_events";
const url = "http://mayadin.tehran.ir/DesktopModules/TM_ArticleList/API/Article/GetList/2766";

Future<List> _queryData(List firstArticleId, List lastArticleId) async {
  final dbHelper = DatabaseHelper.instance;
  firstArticleId = await dbHelper.queryAllRows();
  print('query all rows:');
  firstArticleId.forEach((row) => print(row));

  for (var i = 0; i < firstArticleId.length; i++)
    lastArticleId.add(firstArticleId[i]['articleId']);

  return lastArticleId;
}



Future<Map> getData() async {

  List firstArticleId = new List();
  List lastArticleId = new List();
  List savedArticleId = new List();
  savedArticleId = await _queryData(firstArticleId, lastArticleId);


  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();


  var initializationSettingsAndroid =
  new AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = new IOSInitializationSettings();
  var initializationSettings = new InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: onSelectNotification);



  http.Response response = await http.get(url);

  Map result = new Map();
  result = jsonDecode(response.body);
  print(result.toString());
  int temp = 0;

  for (var i = 0; i < result['list'].length - 1; i++) {
    for (var j = 0; j < savedArticleId.length; j++) {
      if (result['list'][i]['ArticleId'].toString() == savedArticleId[j].toString())
        temp++;
    }
    if (temp == 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('key', true);
      _showNotification(flutterLocalNotificationsPlugin);
    }
    else temp = 0;
  }

  return result;
}




Future onSelectNotification(String payload) async {

  print("Tapped notification");


}





Future _showNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails('notiifcation_channel_id', 'Channel Name', 'here we will show',
    importance: Importance.Max, priority: Priority.High, );

  var iosPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iosPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(0, 'برای مشاهده پیام های جدید کلیک کنید', 'بازار روز همراه', platformChannelSpecifics,
      payload: 'Default_Sound');

}




void backgroundFetchHeadlessTask(String taskId) async {
  print("[BackgroundFetch] Headless event received: $taskId");
  DateTime timestamp = DateTime.now();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Read fetch_events from SharedPreferences
  List<String> events = [];
  String json = prefs.getString(EVENTS_KEY);
  if (json != null) {
    events = jsonDecode(json).cast<String>();
  }

  Map list = await getData();
  // Add new event.
  events.insert(0, "[Headless] $taskId@${list.toString()}");
  // Persist fetch events in SharedPreferences
  prefs.setString(EVENTS_KEY, jsonEncode(events));

  BackgroundFetch.finish(taskId);

//  if (taskId == 'flutter_background_fetch') {
//    BackgroundFetch.scheduleTask(TaskConfig(
//        taskId: "com.transistorsoft.customtask",
//        delay: 5000,
//        periodic: false,
//        forceAlarmManager: true,
//        stopOnTerminate: false,
//        enableHeadless: true
//    ));
//  }
}









class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Home1();
  }
}

class Home1 extends State<Home> {

  bool _enabled = true;
  int _status = 0;
  List<String> _events = [];
  final dbHelper = DatabaseHelper.instance;
  List firstArticleId = new List();
  List lastArticleId = new List();
  List newArticleId = new List();
  Map result = new Map();
  List<String> list = new List<String>();



  @override
  initState() {
    super.initState();
    BackgroundFetch.start().then((int status) {
      print('[BackgroundFetch] start success: $status');
    }).catchError((e) {
      print('[BackgroundFetch] start FAILURE: $e');
    });
    initPlatformState();

    _query();

  }





  Future<void> initPlatformState() async {
    // Load persisted fetch events from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString(EVENTS_KEY);
    if (json != null) {
      setState(() {
        _events = jsonDecode(json).cast<String>();
      });
    }



    // Configure BackgroundFetch.
    BackgroundFetch.configure(BackgroundFetchConfig(
      minimumFetchInterval: 15,
      forceAlarmManager: false,
      stopOnTerminate: false,
      startOnBoot: true,
      enableHeadless: true,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresStorageNotLow: false,
      requiresDeviceIdle: false,
      requiredNetworkType: NetworkType.NONE,
    ), _onBackgroundFetch).then((int status) {
      print('[BackgroundFetch] configure success: $status');
      setState(() {
        _status = status;
      });

    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
      setState(() {
        _status = e;
      });
    });
    // Optionally query the current BackgroundFetch status.
    int status = await BackgroundFetch.status;
    setState(() {
      _status = status;
    });

    if (!mounted) return;
  }




  void _onBackgroundFetch(String taskId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime timestamp = new DateTime.now();
    // This is the fetch-event callback.
    print("[BackgroundFetch] Event received: $taskId");

    prefs.setString(EVENTS_KEY, jsonEncode(_events));

    BackgroundFetch.finish(taskId);
  }




  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.info,
              color: Colors.white,
              size: 30,
            ),
            padding: EdgeInsets.only(left: 10),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: json,
              padding: EdgeInsets.only(right: 10),
              icon: Icon(Icons.notifications, color: Colors.white, size: 30),
            )
          ],
          centerTitle: true,
          title: Text("بازار روز همراه",
              style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 5,
                  fontWeight: FontWeight.w600)),
        ),
        body: Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 15),
                  child: TextField(
                    style:
                        TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 5),
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.search,
                        size: 40,
                      ),
                      hintStyle: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal * 5),
                      hintText: '!در میان نرخ نامه محصولات بگردید',
                      contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 20.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0)),
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: <Widget>[
                        Image.asset("assets/images/vegetables.jpg"),
                        InkWell(
                          onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                            builder: (con) => Maps()
                          )),
                          child: Container(
                            color: Colors.redAccent,
                            height: 65,
                            child: Center(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "نزدیک ترین بازار میوه و تره بار",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 30,
                                )
                              ],
                            )),
                          ),
                        )
                      ],
                    )),
                Expanded(
                  child: GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 0,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1),
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.only(left: 20, right: 20),
                    children: [
                      InkWell(
                        child: Card(
                            color: Colors.lightBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            margin: EdgeInsets.all(10.0),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    "assets/images/shopping.png",
                                    width: 90,
                                    height: 90,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 5,
                                    ),
                                    child: Text(
                                      "فهرست بازارها",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  )
                                ],
                              ),
                            )),
                      ),
                      InkWell(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (con) => Bazaar()
                            )),
                        child: Card(
                            color: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            margin: EdgeInsets.all(10.0),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    "assets/images/fruit.png",
                                    width: 80,
                                    height: 80,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 10,
                                    ),
                                    child: Text(
                                      "نرخ نامه",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  )
                                ],
                              ),
                            )),
                      ),
                      InkWell(
                        child: Card(
                            color: Colors.greenAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            margin: EdgeInsets.all(10.0),
                            child: Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "assets/images/tehran.png",
                                  width: 70,
                                  height: 70,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 10,
                                  ),
                                  child: Text(
                                    "درباره سازمان",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                )
                              ],
                            ))),
                      ),
                      InkWell(
                        child: Card(
                            color: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            margin: EdgeInsets.all(10.0),
                            child: Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "assets/images/teacher.png",
                                  width: 70,
                                  height: 70,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 10,
                                  ),
                                  child: Text(
                                    "مطالب آموزشی",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                )
                              ],
                            ))),
                      ),
                    ],
                  ),
                )
              ],
            )));
  }

  void json() async {

    result = await getJSON();



    setState(() {

      list.clear();


      print(lastArticleId.length);
      int temp = 0;
      var date = new DateTime.now();

      for (var i = 0; i < result['list'].length - 1; i++) {
        var createDate = DateTime.parse(result['list'][i]['CreateDate']);
        var expireDate = DateTime.parse(result['list'][i]['ExpireDate']);
        if (createDate.isBefore(date) && expireDate.isAfter(date)) {
          // compare result['list'][i]['ArticleId'] with lastArticleId[j]
          for (var j = 0; j < lastArticleId.length; j++) {
            if (result['list'][i]['ArticleId'].toString() == lastArticleId[j].toString()) {
              temp++;
            }
          }
          if (temp == 0) {
            newArticleId.add(result['list'][i]['ArticleId']);
            list.add(result['list'][i]['Content']);
          }
          else temp = 0;
        }
      }


      for (var i = 0; i < newArticleId.length; i++)
        _insert(newArticleId[i].toString());

      newArticleId.clear();
      lastArticleId.clear();
      _query();
      
      
      for (var i = 0; i < list.length; i++) {
        list[i] = list[i].replaceAllMapped(new RegExp(r'<.*."*"'), (match) {
          return '';
        });
        list[i] = list[i].replaceAllMapped(new RegExp(r'<.*.>'), (match) {
          return '';
        });
        list[i] = list[i].replaceAll(">", "");
      }


      if (list.length == 0) {
        showDialog(
          context: context,
          builder: (BuildContext context) => EmptyDialogue(
          title: "هیچ پیامی برای نمایش وجود ندارد!",
          description: "شما قبلاً تمامی اطلاعیه ها را مشاهده کرده اید",
          buttonText: "بستن",
        ),
        );
      }
      else {
        showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            title: list,
            buttonText: "بستن",
          ),
        );
      }
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('key', false);
  }



  Future<Map> getJSON() async {

    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else
      throw Exception("No Internet Connection");
  }





  void _insert(String string) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnArticleId : string,
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
  }

  void _query() async {
    firstArticleId = await dbHelper.queryAllRows();
    print('query all rows:');
    firstArticleId.forEach((row) => print(row));

    for (var i = 0; i < firstArticleId.length; i++)
      lastArticleId.add(firstArticleId[i]['articleId']);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool boolean = prefs.getBool('key');
    if (boolean == true)
      json();
  }



}
