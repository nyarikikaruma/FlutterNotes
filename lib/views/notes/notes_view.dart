import 'package:flutter/material.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/main.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/views/constants/routes.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    _notesService.open();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your library of notes.'),
        actions: [
           IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNoteRoute);
            }, 
            icon: Icon(Icons.add)),
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
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(userEmail),
        builder: (context, snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch(snapshot.connectionState){
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                    if (snapshot.hasData){
                      final allNotes = snapshot.data as List<DatabaseNote>;
                      return ListView.builder(
                        itemCount: allNotes.length,
                        itemBuilder: (context, index){
                          print('All data is available');
                          final note = allNotes[index];
                          return ListTile(
                            title: Text(
                              note.text,
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              ),
                          );
                        });
                    } else{
                    return const CircularProgressIndicator();
                    }
                    default:
                    return const CircularProgressIndicator();
                  }
                },
              );
              default:
              return const CircularProgressIndicator();
          }
        }
      ),
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