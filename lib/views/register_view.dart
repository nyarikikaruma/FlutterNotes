import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
                          final usercredentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
                          Navigator.of(context).pushNamedAndRemoveUntil(homeRoute, (route) => false);

                          devtools.log(usercredentials.toString());
                          }
                          on FirebaseAuthException catch(e){
                            if(e.code == 'weak-password'){
                              showErrorDialog(context, 'Weak password, try again');
                            }
                            else if(e.code == 'email-already-in-use'){
                              showErrorDialog(context, 'The email is already in use');
                            }
                            else if(e.code == 'invalid-email'){
                              showErrorDialog(context, 'Invalid email');
                            }
                            else{
                              showErrorDialog(context, 'An error occured');
                            }
                            devtools.log(e.code);
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
