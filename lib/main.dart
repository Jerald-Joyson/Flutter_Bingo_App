import 'package:bingo_1/screens/create_room_screen.dart';
import 'package:bingo_1/screens/join_room_screen.dart';
import 'package:bingo_1/screens/offline_screen.dart';
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
    brightness: Brightness.light,
    primaryColor: Colors.blueGrey[800],
    scaffoldBackgroundColor: Colors.grey[100],
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Colors.blueAccent,
      primary: Colors.blueGrey[800],
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.blueGrey[900],
      elevation: 2,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey[900],
        fontSize: 22,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(
        color: Colors.blueGrey[900],
        fontSize: 16,
      ),
      headlineSmall: TextStyle(
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
    ),
  ),
      home: HomeScreen(),
      routes: {
        JoinRoomScreen.routeName: (context) => JoinRoomScreen(),
        CreateRoomScreen.routeName: (context) => CreateRoomScreen(),
        ScreenOffline.routeName: (context) => ScreenOffline(),
      },
    );
  }
}
