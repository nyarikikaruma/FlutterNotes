import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/views/register_view.dart';

import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    ));
}

class HomePage extends StatelessWidget{
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WifePlanet'),
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
                 print(FirebaseAuth.instance.currentUser);
              return Text('Welcome to WifePlanet');
            default:
            return Text('Loading...');
              }
            },
          ),
        ),
    );
  }
}



