import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

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
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.green
        ),
        body: Center(
          child: FutureBuilder(
            future: Firebase.initializeApp(
                      options: DefaultFirebaseOptions.currentPlatform,
                    ),
            builder: (context, snapshot){
              switch (snapshot.connectionState){
                
                case ConnectionState.done:
              return Column(
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
                TextButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    try{
                    final usercredentials = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
                    print(usercredentials);
                    }
                    on FirebaseAuthException catch(e){
                      print('An error occured');
                      print(e.code);
                    }
                  },
                  child: Text('Login')),
              ],
            );
            default:
            return Text('Loading...');
              }
            },
          ),
        ),
    );
  }
  
  
}