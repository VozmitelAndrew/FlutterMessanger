import 'package:flutter/material.dart';
import 'package:p3/components/MyButton.dart';
import 'LoginRegisterPage.dart';

class ChatsPage extends StatefulWidget {
  final String jwt;
  final String refreshToken;

  const ChatsPage({super.key, required this.jwt, required this.refreshToken});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  void backToLogin() {
    print("BackToLogin");
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginRegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Screen")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: Column(
              children: [
                const Text("Успешная авторизация!"),
                Text("JWT: ${widget.jwt}"),
                Text("Refresh Token: ${widget.refreshToken}"),
              ],
            ),
          ),
          MyButton(text: "Выйти", onTap: backToLogin),
        ],
      ),
    );
  }
}
