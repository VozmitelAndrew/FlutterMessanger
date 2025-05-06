import 'package:flutter/material.dart';
import 'package:p3/pages/LoginRegisterPage.dart';
import 'package:p3/pages/SettingsPage.dart';

import '../logic/AuthenticationService.dart';



class MyDrawer extends StatelessWidget {

  const MyDrawer({super.key});

  void logOut(){
    //TODO поменять localhost в продакшене
    final AuthenticationService authService = HttpAuthService();

    authService.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25.0, top: 25),
                child: ListTile(
                  title: Text("H O M E"),
                  leading: Icon(Icons.home),
                  onTap: (){
                    Navigator.pop(context);
                  },
                ),
              ),


              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: Text("S E T T I N G S"),
                  leading: Icon(Icons.settings),
                  onTap: (){
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                  },
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25),
            child: ListTile(
              internalAddSemanticForOnTap: false,

              title: Text("L O G O U T"),
              leading: Icon(Icons.logout),
              onTap: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginRegisterPage()));
                //TODO unlogin???
              },
            ),
          ),
        ],
      ),
    );
  }
}
