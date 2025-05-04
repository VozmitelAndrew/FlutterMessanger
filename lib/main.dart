import 'package:flutter/material.dart';
import 'package:p3/pages/ChatScreenPage.dart';
import 'package:p3/pages/LoginRegisterPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: "Cursed",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      debugShowCheckedModeBanner: false,
      //home: LoginRegisterPage(),
      home: ChatsPage(jwt: "1", refreshToken: "1"),
    );
  }
}