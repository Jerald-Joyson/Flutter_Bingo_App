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

  final TextEditingController _nameController = TextEditingController();
  final DatabaseReference _roomsRef =
      FirebaseDatabase.instance.reference().child('rooms');

  Future<void> _createRoom(BuildContext context) async {
    String username = _nameController.text.trim();
    if (username.isNotEmpty) {
      // Generate a unique room ID
      String? roomId = _roomsRef.push().key;

      // Create the room in the database
      try {
        await _roomsRef.child(roomId!).set({
          'player1Name': username,
          'player2Name': (await FirebaseDatabase.instance
                      .reference()
                      .child('rooms')
                      .child(roomId)
                      .get())
                  .value is Map
              ? (((await FirebaseDatabase.instance
                          .reference()
                          .child('rooms')
                          .child(roomId)
                          .get())
                      .value as Map)['player2Name'] ??
                  '')
              : '',
        });

        _displayRoomId(context, roomId);
      } catch (error) {
        print("Failed to create room: $error");
      }
    }
  }

  void _displayRoomId(BuildContext context, String roomIdName) {
    String username = _nameController.text.trim();
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          OnlineGameScreen(roomIdName, 'player1', username),
                    ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Create Room'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.12),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create a new Bingo Room',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_nameController.text.trim().isEmpty) return;
                  _createRoom(context);
                },
                icon: const Icon(Icons.check),
                label: const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
