import 'package:flutter/material.dart';
import 'package:p3/components/MyButton.dart';
import 'package:p3/stubs/StubLogicAuth.dart';

import '../components/MyTextField.dart';
import '../logic/AuthenticationService.dart';
import 'ChatsScreenPage.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final AuthenticationService _authService = DummyAuthenticationService();

  Future<void> login() async {
    setState(() {
      _errorMessage = null;
    });
    final AuthResult result = await _authService.login(
      email: emailController.text,
      password: passwordController.text,
    );
    if (result is AuthSuccessLogin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) =>
                  ChatsPage(),
        ),
      );
    } else if (result is AuthFailure) {
      setState(() {
        _errorMessage = result.error;
      });
    }
  }

  Future<void> register() async {
    setState(() {
      _errorMessage = null;
    });
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Пароли не совпадают';
      });
      return;
    }
    final AuthResult result = await _authService.register(
      email: emailController.text,
      username: nicknameController.text,
      tag: tagController.text.isNotEmpty ? tagController.text : null,
      password: passwordController.text,
    );
    if (result is AuthSuccessLogin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) =>
                  ChatsPage(),
        ),
      );
    } else if (result is AuthFailure) {
      setState(() {
        _errorMessage = result.error;
      });
    }
  }

  //TODO - remember me
  bool rememberMe = false;

  //TODO - add tag
  final TextEditingController tagController = TextEditingController();

  //TODO - add showEmail
  bool showEmail = true;

  bool isLoginMode = true;
  final bool deletePasswordWhenEntered = true;
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? _errorMessage;

  void switchModes() {
    setState(() {
      isLoginMode = !isLoginMode;
    });
    print(isLoginMode);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nuke",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: "Cursed",
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.2,
          screenHeight * (isLoginMode ? 0.15 : 0.1),
          screenWidth * 0.2,
          screenHeight * (isLoginMode ? 0.2 : 0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Visibility(
              visible: !isLoginMode,
              child: MyTextField(
                hintText: "Nickname:",
                controller: nicknameController,
                obscureText: false,
              ),
            ),

            MyTextField(
              hintText: "Email:",
              controller: emailController,
              obscureText: false,
            ),

            Visibility(
              visible: !isLoginMode,
              child: MyTextField(
                hintText: "tag:",
                controller: tagController,
                obscureText: true,
              ),
            ),

            MyTextField(
              hintText: "Password:",
              controller: passwordController,
              obscureText: true,
            ),

            Visibility(
              visible: !isLoginMode,
              child: MyTextField(
                hintText: "Confirm password:",
                controller: confirmPasswordController,
                obscureText: true,
              ),
            ),

            Visibility(
              visible: !isLoginMode,
              child: CheckboxListTile(
                title: Text("Show email"),
                value: showEmail,
                onChanged: (bool? value) {
                  setState(() {
                    showEmail = value!;
                  });
                },
              ),
            ),

            // Visibility(
            //   visible: isLoginMode,
            //   child: CheckboxListTile(
            //     title: Text("Remember me"),
            //     value: rememberMe,
            //     onChanged: (bool? value) {
            //       setState(() {
            //         rememberMe = value!;
            //       });
            //     },
            //   ),
            // ),
            CheckboxListTile(
              title: Text("Remember me"),
              value: rememberMe,
              onChanged: (bool? value) {
                setState(() {
                  rememberMe = value!;
                });
              },
            ),

            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child:
                  isLoginMode
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyButton(text: "Login", onTap: login),
                          MyButton(
                            text: "I don't have an account",
                            onTap: switchModes,
                          ),
                        ],
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyButton(text: "Register", onTap: register),
                          MyButton(
                            text: "I have an account",
                            onTap: switchModes,
                          ),
                        ],
                      ),
            ),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade200),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  clear() {
    print("clear??");
    setState(() {
      if (!isLoginMode) {
        confirmPasswordController.clear();
        return;
      }
      passwordController.clear();
    });
  }
}
