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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomCodeController = TextEditingController();

  void dispose() {
    _nameController.dispose();
    _roomCodeController.dispose();
  }

  // final DatabaseReference _roomsRef =
  //     // ignore: deprecated_member_use
  //     FirebaseDatabase.instance.reference().child('rooms');

  // void _joinRoom(BuildContext context) async {
  //   String username = _usernameController.text.trim();
  //   String roomId = _roomIdController.text.trim();

  //   if (username.isNotEmpty && roomId.isNotEmpty) {
  //     try {
  //       DatabaseEvent event = await _roomsRef.child(roomId).once();
  //       DataSnapshot snapshot = event.snapshot;

  //       if (snapshot.value != null && !snapshot.hasChild("player2")) {
  //         await _roomsRef.child(roomId).update({
  //           'player2': username,
  //         });
  //         // ignore: use_build_context_synchronously
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => OnlineGameScreen(
  //               roomId.toString(),
  //               playerId.toString(),
  //               username.toString(),
  //             ),
  //           ),
  //         );
  //         // Fluttertoast.showToast(
  //         //   msg: 'Joined room $roomId as player 2',
  //         //   toastLength: Toast.LENGTH_LONG,
  //         //   gravity: ToastGravity.BOTTOM,
  //         // );
  //       } else {
  //         Fluttertoast.showToast(
  //           msg: 'Room is full or does not exist',
  //           toastLength: Toast.LENGTH_LONG,
  //           gravity: ToastGravity.BOTTOM,
  //         );
  //       }
  //     } catch (error) {
  //       print("Failed to join room: $error");
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Join Room'),
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
                'Join an existing Bingo Room',
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
              TextField(
                controller: _roomCodeController,
                decoration: InputDecoration(
                  labelText: 'Room Code',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final name = _nameController.text.trim();
                  final roomId = _roomCodeController.text.trim();
                  if (name.isEmpty || roomId.isEmpty) return;

                  final roomRef = FirebaseDatabase.instance
                      .reference()
                      .child('rooms')
                      .child(roomId);
                  final snap = await roomRef.get();
                  if (!snap.exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Room not found')),
                    );
                    return;
                  }

                  await roomRef.update({'player2Name': name});

                  // Navigate to OnlineGameScreen as player2
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OnlineGameScreen(roomId, 'player2', name),
                    ),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Join'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
