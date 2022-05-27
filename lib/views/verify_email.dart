import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/main.dart';
import 'package:mynotes/views/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async{
              switch(value){
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
          )
        ],),
      body: Column(children: [
          const Text('Please verify your email address'),
          TextButton(onPressed: () async{
            final user = FirebaseAuth.instance.currentUser;
            await user?.sendEmailVerification();
          }, child: const Text('Send email verification'))
        ]),
    );
    
  }
}
