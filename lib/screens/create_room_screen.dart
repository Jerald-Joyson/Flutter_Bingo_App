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
  String playerId = 'player1';
  static String routeName = '/create-room';

  final TextEditingController _usernameController = TextEditingController();
  final DatabaseReference _roomsRef =
      FirebaseDatabase.instance.reference().child('rooms');

  Future<void> _createRoom(BuildContext context) async {
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
      } catch (error) {
        print("Failed to create room: $error");
      }
    }
  }

  void moveToNextScreen(
    BuildContext context,
    String roomIdName,
    String username,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnlineGameScreen(
          roomIdName,
          playerId,
          username,
        ),
      ),
    );
  }

  void _displayRoomId(BuildContext context, String roomIdName) {
    String username = _usernameController.text.trim();
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
                  moveToNextScreen(context, roomIdName, username);
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
                    onTap: () {
                      _createRoom(context);
                      _usernameController.clear();
                    },
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
