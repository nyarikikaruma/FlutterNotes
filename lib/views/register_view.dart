import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'dart:developer' as devtools show log;

import 'package:mynotes/views/constants/routes.dart';
import 'package:mynotes/views/utilities/show_error_dialog.dart';


class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: Text('Register'),),
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
                        Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                      }, child: const Text('Login')),
                      TextButton(
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;
                          try{
                          await AuthService.firebase().createUser(email: email, password: password);
                          AuthService.firebase().sendEmailVerification();
                          Navigator.of(context).pushNamedAndRemoveUntil(homeRoute, (route) => false);
                          }
                          on WeakPasswordAuthException{
                            showErrorDialog(context, 'Weak password, try again');
                          }
                          on EmailAlreadyInUseAuthException{
                            showErrorDialog(context, 'Email already in use');
                          }
                          on InvalidEmailAuthException{
                            showErrorDialog(context, 'Invalid email');
                          }
                          on GenerericAuthException{
                            showErrorDialog(context, 'Something went wrong');
                          }
                        },
                        child: const Text('Register')),
                    ],
                  ),
                ],
              ),
    );
  }
}
