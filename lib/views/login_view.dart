import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/main.dart';
import 'package:mynotes/views/register_view.dart';
import 'dart:developer' as devtools show log;


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
      appBar: AppBar(title: Text('Login'),),
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
                        Navigator.of(context).pushNamedAndRemoveUntil('/register/', (route) => false);
                      }, child: const Text('Register')),
                      TextButton(
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;
                          try{
                          final usercredentials = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
                          Navigator.of(context).pushNamedAndRemoveUntil('/home/', (route) => false);

                          devtools.log(usercredentials.toString());
                          }
                          on FirebaseAuthException catch(e){
                            devtools.log('An error occured');
                            devtools.log(e.code);
                          }
                        },
                        child: Text('Login')),
                    ],
                  ),
                ],
              ),
    );
  }
  
  
}