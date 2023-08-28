import 'package:bingo_1/screens/online_game_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../responsive/responsive.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_textfield.dart';

class JoinRoomScreen extends StatelessWidget {
  String playerId = 'player2';
  static String routeName = '/Join-room';
  JoinRoomScreen({super.key});
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _roomIdController = TextEditingController();

  void dispose() {
    _usernameController.dispose();
    _roomIdController.dispose();
  }

  final DatabaseReference _roomsRef =
      // ignore: deprecated_member_use
      FirebaseDatabase.instance.reference().child('rooms');

  void _joinRoom(BuildContext context) async {
    String username = _usernameController.text.trim();
    String roomId = _roomIdController.text.trim();

    if (username.isNotEmpty && roomId.isNotEmpty) {
      try {
        DatabaseEvent event = await _roomsRef.child(roomId).once();
        DataSnapshot snapshot = event.snapshot;

        if (snapshot.value != null && !snapshot.hasChild("player2")) {
          await _roomsRef.child(roomId).update({
            'player2': username,
          });
          // ignore: use_build_context_synchronously
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
          // Fluttertoast.showToast(
          //   msg: 'Joined room $roomId as player 2',
          //   toastLength: Toast.LENGTH_LONG,
          //   gravity: ToastGravity.BOTTOM,
          // );
        } else {
          Fluttertoast.showToast(
            msg: 'Room is full or does not exist',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
        }
      } catch (error) {
        print("Failed to join room: $error");
      }
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
              const CustomText(
                shadows: [
                  Shadow(
                    blurRadius: 40,
                    color: Colors.black,
                  )
                ],
                text: 'Join Room',
                fontSize: 70,
              ),
              SizedBox(
                height: size.height * 0.08,
              ),
              CustomTextField(
                controller: _usernameController,
                hintText: 'Enter Your Nickname',
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                controller: _roomIdController,
                hintText: 'Enter Game ID',
              ),
              SizedBox(
                height: size.height * 0.045,
              ),
              CustomButton(
                onTap: () {
                  _joinRoom(context);
                  _roomIdController.clear();
                  _usernameController.clear();
                },
                text: 'Join',
              )
            ],
          ),
        ),
      ),
    );
  }
}
