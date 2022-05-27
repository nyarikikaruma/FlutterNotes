import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/views/constants/routes.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email.dart';
import 'firebase_options.dart';
import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        registerRoute: (context) => const RegisterView(),
        loginRoute: (context) => const LoginView(),
        homeRoute: (context) => const NotesView(),
        VerifyEmailRoute: (context) => const VerifyEmailView(),
      }
    ));
}


class HomePage extends StatelessWidget{
  const HomePage({Key? key}) : super(key: key);

 @override
  Widget build(BuildContext context) {
    return FutureBuilder(
            future: Firebase.initializeApp(
                      options: DefaultFirebaseOptions.currentPlatform,
                    ),
            builder: (context, snapshot){
              switch (snapshot.connectionState){
                 case ConnectionState.done:
                 final user = FirebaseAuth.instance.currentUser;
                 if(user !=null){
                   if(user.emailVerified){
                     return const NotesView();
                  //  return Text('Welcome ${user.email}');
                   }
                    else{
                      return const VerifyEmailView();
                    }
                 }else{
                    return const LoginView();
                 }
                 default:
                  return const Text('Loading');
              }
            },
          );
  }
}

enum MenuAction { login, register, logout }

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
                await FirebaseAuth.instance.signOut();
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
                  await FirebaseAuth.instance.signOut();
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

Future<bool> showLogOutDialog(BuildContext context){
  return showDialog<bool>(
    context: context, 
    builder: (context) {
    return AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        FlatButton(
          child: const Text('Yes'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        FlatButton(
          child: const Text('No'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
    
}).then((value) => value ?? false);
}






