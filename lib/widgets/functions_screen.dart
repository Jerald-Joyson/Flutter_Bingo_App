import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../screens/online_game_screen.dart';
import 'custom_text.dart';

void WaitingScreen(BuildContext context, String roomId) {
  final size = MediaQuery.of(context).size;
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: size.height * 0.55,
          height: size.height * 0.55,
          color: Colors.white, // <-- Set bg color to pink
          alignment: Alignment.center,
          margin: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  'Wating For other Player to Join....!!',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                CircularProgressIndicator(),
              ],
            ), // Use any loading animation you prefer
          ),
        );
      });
}

void WinnerScreen(
  BuildContext context,
  String winnerName,
  String roomId,
  String playerId,
  String username,
) {
  DatabaseReference _roomRef =
      FirebaseDatabase.instance.reference().child('rooms');
  final size = MediaQuery.of(context).size;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        // Create a dialog widget
        child: Container(
          width: size.height * 0.55,
          height: size.height * 0.55,
          color: Colors.white,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$winnerName is the winner....!!',
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: Colors.black,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 2,
                    top: 2,
                    left: 5,
                    right: 5,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return OnlineGameScreen(
                            roomId,
                            playerId,
                            username,
                          );
                        }),
                      );
                      _roomRef.child(roomId).child('winner').remove();
                      _roomRef.child(roomId).update({
                        'message': '',
                      });
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _sendMessage(
  BuildContext context,
  String message,
  String roomId,
  String playerId,
) {
  if (message.isNotEmpty) {
    DatabaseReference _roomRef =
        FirebaseDatabase.instance.reference().child('rooms');

    _roomRef.child(roomId).update({
      'ChatMessage': '$playerId:$message',
    }).then((_) {
      Fluttertoast.showToast(
        msg: 'Message sent!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
    _roomRef.child(roomId).update({
      'ChatMessage': ' ',
    });
  }
}

void ChatScreen(
  BuildContext context,
  String roomId,
  String playerId,
  String username,
) {
  TextEditingController _messageController = TextEditingController();
  final size = MediaQuery.of(context).size;
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: size.height * 0.55,
            height: 200,
            color: Colors.white,
            alignment: Alignment.center,
            margin: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: Colors.red),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _sendMessage(
                        context,
                        _messageController.text.trim(),
                        roomId,
                        playerId,
                      );
                      _messageController.clear();
                    },
                    child: Text(
                      'SEND',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}

void ShowResultScreen(
  BuildContext context,
) {
  String p1Name = "Player 1";
  String p1Result = "0";
  String p2Name = "Player 2";
  String p2Result = "0";

  DatabaseReference _roomRef =
      FirebaseDatabase.instance.reference().child('rooms');
  final size = MediaQuery.of(context).size;
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: size.height * 0.55,
            height: 200,
            color: Colors.white,
            alignment: Alignment.center,
            margin: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: Colors.red),
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomText(
                    shadows: [
                      Shadow(
                        blurRadius: 40,
                        color: Colors.black,
                      )
                    ],
                    text: '$p1Name : $p1Result',
                    fontSize: 18,
                  ),
                  SizedBox(height: 10),
                  CustomText(
                    shadows: [
                      Shadow(
                        blurRadius: 40,
                        color: Colors.black,
                      )
                    ],
                    text: '$p2Name : $p2Result',
                    fontSize: 18,
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
