import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OnlineGameScreen extends StatefulWidget {
  final String roomId;
  final String playerId;
  final String username;

  OnlineGameScreen(
    this.roomId,
    this.playerId,
    this.username,
  );

  @override
  _OnlineGameScreenState createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _roomRef =
      FirebaseDatabase.instance.reference().child('rooms');

  bool _isPlayer1 = false;
  bool _isPlayer2 = false;

  @override
  void initState() {
    super.initState();

    _roomRef.child(widget.roomId).onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null &&
          event.snapshot.value is Map<String, dynamic>) {
        final Map<String, dynamic> snapshotValue =
            event.snapshot.value as Map<String, dynamic>;
        setState(() {
          _isPlayer1 = snapshotValue.containsKey('player1');
          _isPlayer2 = snapshotValue.containsKey('player2');
        });
      }
    });
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      String sender = widget.username;
      String messageType = _isPlayer1 ? 'player1' : 'player2';

      _roomRef.child(widget.roomId).update({
        'message': '$sender: $message',
      }).then((_) {
        Fluttertoast.showToast(
          msg: 'Message sent!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        setState(() {
          _messageController.clear();
        });
      }).catchError((error) {
        print("Failed to send message: $error");
      });
    }
  }

  void _exitChat() {
    _roomRef.child(widget.roomId).remove().then((_) {
      Navigator.of(context).pop(); // Navigate back to the previous screen
    }).catchError((error) {
      print("Failed to exit chat: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSendButtonEnabled = _isPlayer1 || (_isPlayer2 && _isPlayer1);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _roomRef.child(widget.roomId).onValue,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  String message = (snapshot.data?.snapshot.value
                          as Map<dynamic, dynamic>?)?['message'] ??
                      '';
                  return SingleChildScrollView(
                    child: Text(message),
                  );
                },
              ),
            ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Message',
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: isSendButtonEnabled ? _sendMessage : null,
                  child: Text('Send'),
                ),
                ElevatedButton(
                  onPressed: _exitChat,
                  child: Text('Exit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


/*

import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_text.dart';

class OnlineGameScreen extends StatefulWidget {
  String? roomId;
  String? playerId;
  String? playerName;
  OnlineGameScreen(this.roomId, this.playerId, this.playerName, {super.key});

  @override
  _OnlineGameScreenState createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  late DatabaseReference _roomsRef;

  List<int> matrixNumbers = [];
  bool refreshButtonVisible = true;
  bool saveButtonClicked = false;
  List<int> clickedBoxIndices = [];
  String appBarText = " ";
  String save_clear = "Save";

  @override
  void initState() {
    super.initState();
    generateMatrixNumbers();
    _roomsRef = FirebaseDatabase.instance
        .reference()
        .child('rooms')
        .child('${widget.roomId}')
        .child('${widget.playerId}');
  }

  void sendMessage(String message) {
    if (message != "") {
      _roomsRef.child("message").set(message);
      int index = findIndexForNumber(message);
      onBoxClicked(index);
    } else {
      Fluttertoast.showToast(
        msg: 'Please enter a message.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  int findIndexForNumber(String number) {
    return matrixNumbers.indexOf(int.parse(number));
  }

  void generateMatrixNumbers() {
    var random = Random();
    var numbers = List.generate(25, (index) => index + 1);
    numbers.shuffle();

    setState(() {
      matrixNumbers = numbers;
    });
  }

  void refreshMatrix() {
    generateMatrixNumbers();
    clearClickedBoxIndices();
  }

  void clearClickedBoxIndices() {
    setState(() {
      clickedBoxIndices.clear();
      appBarText = "";
    });
  }

  void saveMatrix() {
    setState(() {
      refreshButtonVisible = false;
      appBarText = "";
      save_clear = "Clear";
      if (widget.playerId == 'player1') {
        saveButtonClicked = true;
      }
      if (widget.playerId == 'player2') {
        saveButtonClicked = false;
      }
    });
    clearClickedBoxIndices();
  }

  void bingo() {
    setState(() {
      refreshButtonVisible = true;
      saveButtonClicked = false;
      save_clear = "Save";
    });
  }

  int getNumberAtIndex(int index) {
    if (index >= 0 && index < matrixNumbers.length) {
      return matrixNumbers[index];
    } else {
      return -1; // Return a sentinel value to indicate an invalid index
    }
  }

  void onBoxClicked(int index) {
    if (saveButtonClicked) {
      if (!clickedBoxIndices.contains(index)) {
        setState(() {
          clickedBoxIndices.add(index);
        });
        int numberInBox = getNumberAtIndex(index);

        sendMessage("$numberInBox");

        // Fluttertoast.showToast(
        //   msg: "Clicked Element is: $numberInBox",
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.CENTER,
        // );
        checkCombinations();
      }
    }
  }

  void checkCombinations() {
    final combinations = [
      [0, 1, 2, 3, 4],
      [5, 6, 7, 8, 9],
      [10, 11, 12, 13, 14],
      [15, 16, 17, 18, 19],
      [20, 21, 22, 23, 24],
      [0, 5, 10, 15, 20],
      [1, 6, 11, 16, 21],
      [2, 7, 12, 17, 22],
      [3, 8, 13, 18, 23],
      [4, 9, 14, 19, 24],
      [0, 6, 12, 18, 24],
      [4, 8, 12, 16, 20],
    ];

    int combinationCount = 0;
    for (var combination in combinations) {
      if (combination.every((index) => clickedBoxIndices.contains(index))) {
        combinationCount++;
      }
    }

    String letter;
    switch (combinationCount) {
      case 1:
        letter = "B";
        break;
      case 2:
        letter = "BI";
        break;
      case 3:
        letter = "BIN";
        break;
      case 4:
        letter = "BING";
        break;
      case 5:
        letter = "BINGO";
        bingo();
        break;
      default:
        letter = "";
        break;
    }

    if (combinationCount > 0) {
      setState(() {
        appBarText = letter;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: "BINGO GAME"),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 10,
              ),
              Center(
                child: CustomText(
                  shadows: const [
                    Shadow(
                      blurRadius: 40,
                      color: Colors.black,
                    )
                  ],
                  text: appBarText,
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: size.height * 0.55,
                height: size.height * 0.55,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 2.0,
                    mainAxisSpacing: 2.0,
                  ),
                  itemCount: matrixNumbers.length,
                  itemBuilder: (context, index) {
                    bool isClicked = clickedBoxIndices.contains(index);
                    return GestureDetector(
                      onTap: () => onBoxClicked(index),
                      child: Container(
                        margin: EdgeInsets.all(2.0),
                        color: isClicked ? Colors.black : Colors.blueGrey,
                        child: Center(
                          child: Text(
                            matrixNumbers[index].toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: size.height * 0.07,
              ),
              Container(
                width: size.height * 0.40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                      visible: refreshButtonVisible,
                      child: ElevatedButton(
                        onPressed: refreshMatrix,
                        child: Text(
                          'Refresh',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          fixedSize: Size(100, 40),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: saveMatrix,
                      child: Text(
                        save_clear,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          fixedSize: Size(100, 40)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/