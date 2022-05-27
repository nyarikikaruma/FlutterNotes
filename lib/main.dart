import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/constants/routes.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email.dart';
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
        verifyEmailRoute: (context) => const VerifyEmailView(),
      }
    ));
}


class HomePage extends StatelessWidget{
  const HomePage({Key? key}) : super(key: key);

 @override
  Widget build(BuildContext context) {
    return FutureBuilder(
            future: AuthService.firebase().initialize(),
            builder: (context, snapshot){
              switch (snapshot.connectionState){
                 case ConnectionState.done:
                 final user = AuthService.firebase().currentUser;
                 devtools.log('user: $user');
                 if(user !=null){
                   if(user.isEmailVerified){
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






