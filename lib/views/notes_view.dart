import 'package:flutter/material.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/main.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/constants/routes.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {           
              switch(value){
                case MenuAction.login:
                  Navigator.of(context).pushNamed(loginRoute);
                  break;
                case MenuAction.register:
                  Navigator.of(context).pushNamed(registerRoute);
                  break;
                case MenuAction.logout:
                final logout = await showLogOutDialog(context);
                if(logout){
                await AuthService.firebase().logOut();
                Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);

                }

                  break;
              }
              },
            itemBuilder: (context){
              return const [
               PopupMenuItem<MenuAction>(
            value: MenuAction.logout,
            child: Text('Logout'),
              )
              ];
            }
          ),
        ],),
      body: const Text('Notes'),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Register'),
              onTap: () {
                Navigator.of(context).pushNamed(registerRoute);
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
               Future<void> _signOut() async {
                  await AuthService.firebase().logOut();

                }
                Navigator.of(context).pushNamed(loginRoute);
              },
            ),
          ],
        ),
      ),
    );
    
  }
}