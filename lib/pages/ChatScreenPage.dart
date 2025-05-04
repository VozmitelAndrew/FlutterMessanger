import 'package:flutter/material.dart';
import 'package:p3/components/MyButton.dart';
import 'package:p3/components/MyDrawer.dart';
import 'LoginRegisterPage.dart';

class ChatsPage extends StatefulWidget {
  final String jwt;
  final String refreshToken;

  const ChatsPage({super.key, required this.jwt, required this.refreshToken});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  List<Map<String, String>> chats = [
    {
      "name": "Пипипопа",
      "lastMessage": "henlo?",
      "time": "15:20",
      "avatarUrl": "",
    },
    {
      "name": "Рабочий чат",
      "lastMessage": "отдыхаем товарищи",
      "time": "14:10",
      "avatarUrl": "",
    },
    {
      "name": "Mom",
      "lastMessage": "henlo?",
      "time": "13:00",
      "avatarUrl": "",
    },
  ];

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
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      chat["name"]![0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    chat["name"] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(chat["lastMessage"] ?? ""),
                  trailing: Text(chat["time"] ?? ""),
                  onTap: () {

                  },
                );
              },
            ),
          ),
        ],
      ),
      drawer: MyDrawer(),
    );
  }
}
