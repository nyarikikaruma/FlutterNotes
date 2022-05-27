import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/views/constants/routes.dart';
import 'dart:developer' as devtools show log;

import 'package:mynotes/views/utilities/show_error_dialog.dart';

import '../services/auth/auth_service.dart';


class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
 late final TextEditingController _email;
  late final TextEditingController _password;

@override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'),),
      body: Column(
                children: [
                  TextField(
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'Email'),
                  ),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(hintText: 'Password'),
                  
                  ),
                  Row(
                    children: [
                      TextButton(onPressed: () {
                        // Return to register view.
                        Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
                      }, child: const Text('Register')),
                      TextButton(
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;
                          try{
                          AuthService.firebase().logIn(email: email, password: password);
                          final user = AuthService.firebase().currentUser;
                          if(user?.isEmailVerified ?? false){
                            // User is verified.
                          Navigator.of(context).pushNamedAndRemoveUntil(homeRoute, (route) => false);
                          }
                          else{
                            // User is not verified.
                          Navigator.of(context).pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
                          }
                          }
                          on UserNotFoundAuthException{
                            await showErrorDialog(context, 'User not found');
                          }
                          on WrongPasswordAuthException{
                              await showErrorDialog(context, 'Wrong password');

                          }
                          on GenerericAuthException{
                              await showErrorDialog(context, 'Error occured');

                          }
                        },
                        child: const Text('Login')),
                    ],
                  ),
                ],
              ),
    );
  }
  
  
}

