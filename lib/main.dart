import 'package:flutter/material.dart';
import 'package:p3/pages/LoginRegisterPage.dart';
import 'logic/AuthenticationService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HttpAuthService().init();
  final isLoggedIn = HttpAuthService().tokens != null;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}



class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NUKE',
      theme: ThemeData(
        fontFamily: "Cursed",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? LoginRegisterPage() : LoginRegisterPage(),
      //home: ChatsPage(),
    );
  }
}