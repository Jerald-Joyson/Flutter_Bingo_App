import 'package:bingo_1/screens/create_room_screen.dart';
import 'package:bingo_1/screens/join_room_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import '../screens/home_screen.dart';
import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("Before Firebase initialization");
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCh6-0KfuoVRIFHLApFeFNY3xa50RMG_Sc",
      appId: "1:45075867229:android:9a8c1ec8b8b66738530fb4",
      authDomain: "flutterbingoapp.firebaseapp.com",
      databaseURL: "https://flutterbingoapp-default-rtdb.firebaseio.com/",
      messagingSenderId: "45075867229",
      projectId: "flutterbingoapp",
    ),
  );
  print("After Firebase initialization");
  runApp(const MyApp());
}
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bingo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: HomeScreen(),
      routes: {
        JoinRoomScreen.routeName: (context) => JoinRoomScreen(),
        CreateRoomScreen.routeName: (context) => CreateRoomScreen(),
      },
    );
  }
}
