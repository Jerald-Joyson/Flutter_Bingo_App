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

  CreateRoomScreen({Key? key}) : super(key: key);

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
    String username = _usernameController.text.trim();
    if (username.isNotEmpty) {
      // Generate a unique room ID
      String? roomId = _roomsRef.push().key;

      // Create the room in the database
      _roomsRef.child(roomId!).set({
        'player1': username,
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
                    builder: (context) => OnlineGameScreen(roomId: roomId),
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
