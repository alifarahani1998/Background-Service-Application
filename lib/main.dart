import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'ui/Home.dart';


void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "بازار روز همراه",
    theme: ThemeData(
      primaryColor: Colors.blueGrey,
      fontFamily: "B_family"
    ),
    home: Home(),
  ));

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}


