import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../responsive/responsive.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_textfield.dart';
import 'online_game_screen.dart';
import 'package:flutter/services.dart';

class CreateRoomScreen extends StatelessWidget {
  static String routeName = '/create-room';

  final TextEditingController _usernameController = TextEditingController();
  final DatabaseReference _roomsRef =
      FirebaseDatabase.instance.reference().child('rooms');

  Future<void> _createRoom(BuildContext context) async {
    String playerId = 'player1';
    String username = _usernameController.text.trim();
    if (username.isNotEmpty) {
      // Generate a unique room ID
      String? roomId = _roomsRef.push().key;

      // Create the room in the database
      try {
        await _roomsRef.child(roomId!).set({
          'player1': username,
          'message': '',
        });

        _displayRoomId(context, roomId);

        _roomsRef.child(roomId).onValue.listen((DatabaseEvent event) {
          if (event.snapshot.value != null &&
              event.snapshot.value is Map<String, dynamic>) {
            final Map<String, dynamic> snapshotValue =
                event.snapshot.value as Map<String, dynamic>;

            if (snapshotValue.containsKey('player2')) {
              String? player2Username = snapshotValue['player2'] as String?;
              if (player2Username != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OnlineGameScreen(
                      roomId.toString(),
                      playerId.toString(),
                      username.toString(),
                    ),
                  ),
                );
              }
            }
          }
        });
      } catch (error) {
        print("Failed to create room: $error");
      }
    }
  }

  void _displayRoomId(BuildContext context, String roomIdName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        return Dialog.fullscreen(
          backgroundColor: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(
                      text:
                          roomIdName)); // Close the bottom sheet after copying
                  Fluttertoast.showToast(
                    msg: 'Room ID copied to clipboard',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        5), // Set the background color here
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      '$roomIdName',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.06),
              const Text(
                'Share the Room ID..(^_^)',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w300),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: "BINGO GAME"),
      body: Responsive(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CustomText(
                    shadows: [
                      Shadow(
                        blurRadius: 40,
                        color: Colors.black,
                      )
                    ],
                    text: 'Create Room',
                    fontSize: 70,
                  ),
                  SizedBox(height: size.height * 0.08),
                  CustomTextField(
                    controller: _usernameController,
                    hintText: 'Enter Your Nickname',
                  ),
                  SizedBox(height: size.height * 0.045),
                  CustomButton(
                    onTap: () => _createRoom(context),
                    text: 'Create',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/*
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../responsive/responsive.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_textfield.dart';
import 'online_game_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  static String routeName = '/create-room';

  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  late TextEditingController roomIdController = TextEditingController();

  void displayRoomId(String roomIdName) {
    setState(() {
      firstColumnVisible = false;
      secondColumnVisible = true;
      roomIdController = TextEditingController(
        text: roomIdName,
      );
    });
  }

  @override
  void dispose() {
    roomIdController.dispose();
    super.dispose();
  }

  final TextEditingController _usernameController = TextEditingController();

  final DatabaseReference _roomsRef =
      // ignore: deprecated_member_use
      FirebaseDatabase.instance.reference().child('rooms');

  bool firstColumnVisible = true;
  bool secondColumnVisible = false;

  Future _createRoom(BuildContext context) async {
    String playerId = 'player1';
    String username = _usernameController.text.trim();
    if (username.isNotEmpty) {
      // Generate a unique room ID
      String? roomId = _roomsRef.push().key;

      // Create the room in the database
      _roomsRef.child(roomId!).set({
        'player1': username,
        'message': '',
      }).then((_) {
        // Display room ID in toast

        displayRoomId(roomId);

        // Fluttertoast.showToast(
        //   msg: 'Room created! Room ID: $roomId',
        //   toastLength: Toast.LENGTH_LONG,
        //   gravity: ToastGravity.BOTTOM,
        // );

        // Listen for changes in the room
        _roomsRef.child(roomId).onValue.listen((DatabaseEvent event) {
          if (event.snapshot.value != null &&
              event.snapshot.value is Map<String, dynamic>) {
            final Map<String, dynamic> snapshotValue =
                event.snapshot.value as Map<String, dynamic>;

            if (snapshotValue.containsKey('player2')) {
              String? player2Username = snapshotValue['player2'] as String?;
              if (player2Username != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OnlineGameScreen(roomId.toString(),
                        playerId.toString(), username.toString()),
                  ),
                );
                // Fluttertoast.showToast(
                //   msg: 'Player 2 ($player2Username) has joined the room!',
                //   toastLength: Toast.LENGTH_LONG,
                //   gravity: ToastGravity.BOTTOM,
                // );
              }
            }
          }
        });
      }).catchError((error) {
        print("Failed to create room: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: "BINGO GAME"),
      body: Responsive(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                visible: firstColumnVisible,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CustomText(
                      shadows: [
                        Shadow(
                          blurRadius: 40,
                          color: Colors.black,
                        )
                      ],
                      text: 'Create Room',
                      fontSize: 70,
                    ),
                    SizedBox(
                      height: size.height * 0.08,
                    ),
                    CustomTextField(
                      controller: _usernameController,
                      hintText: 'Enter Your Nickname',
                    ),
                    SizedBox(
                      height: size.height * 0.045,
                    ),
                    CustomButton(
                        onTap: () => _createRoom(context),
                        // _socketMethods.createRoom(_nameController.text),
                        text: 'Create'),
                  ],
                ),
              ),
              Visibility(
                visible: secondColumnVisible,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("waiting for a player to join....."),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: roomIdController,
                      hintText: '',
                      isReadOnly: true,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
*/