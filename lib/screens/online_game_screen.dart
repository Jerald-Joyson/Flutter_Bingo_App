// ignore_for_file: avoid_print, unused_local_variable, library_private_types_in_public_api, deprecated_member_use, non_constant_identifier_names, sized_box_for_whitespace

import 'dart:async';
import 'dart:math';
import '../widgets/functions_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_text.dart';

class OnlineGameScreen extends StatefulWidget {
  final String roomId;
  final String playerId;
  final String username;

  const OnlineGameScreen(this.roomId, this.playerId, this.username,
      {super.key});

  @override
  _OnlineGameScreenState createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  final TextEditingController _messageController = TextEditingController();
  late StreamSubscription _messageListener;
  StreamSubscription? _chatMessageListener;
  List<int> matrixNumbers = [];
  bool refreshButtonVisible = true;
  bool saveButtonClicked = false;
  List<int> clickedBoxIndices = [];
  String appBarText = " ";
  String save_clear = "Save";

  late final DatabaseReference _roomRef =
      FirebaseDatabase.instance.reference().child('rooms');

  @override
  void initState() {
    super.initState();
    generateMatrixNumbers();
    _listenForMessages(widget.roomId, widget.playerId);
  }

  @override
  void dispose() {
    _messageListener.cancel();
    _chatMessageListener?.cancel();
    super.dispose();
  }

  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      String sender = widget.playerId;

      _roomRef.child(widget.roomId).update({
        'message': '$sender: $message',
      }).then((_) {
        Fluttertoast.showToast(
          msg: 'send: $message',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        setState(() {
          saveButtonClicked = false;
          _messageController.clear();
        });
      }).catchError((error) {
        print("Failed to send message: $error");
      });
    }
  }

  void _exitChat() {
    _roomRef.child(widget.roomId).remove().then((_) {
      Navigator.of(context).pop();
      if (widget.playerId == 'player1') {
        Navigator.of(context).pop();
      }
    }).catchError((error) {
      print("Failed to exit chat: $error");
    });
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

  void clearClickedBoxIndices() {
    _roomRef.child(widget.roomId).update({
      'message': '',
    });
    setState(() {
      clickedBoxIndices.clear();
      appBarText = "";
    });
  }

  bool moveToNextScreen() {
    int value = 0;
    _roomRef.child(widget.playerId).onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null &&
          event.snapshot.value is Map<String, dynamic>) {
        final Map<String, dynamic> snapshotValue =
            event.snapshot.value as Map<String, dynamic>;

        if (snapshotValue.containsKey('player2')) {
          String? player2Username = snapshotValue['player2'] as String?;
          if (player2Username != null) {
            value = 1;
          }
          value = 1;
        }
      }
    });
    if (value == 1) {
      return true;
    } else {
      return false;
    }
  }

  void declareWinner() {
    String sender = widget.playerId;
    _roomRef.child(widget.roomId).update({
      'winner': '$sender: winner',
    }).then((_) {
      _messageListener.cancel();
      WinnerScreen(
        context,
        widget.username,
        widget.roomId,
        widget.playerId,
        widget.username,
      );
      Fluttertoast.showToast(
        msg: 'Winner Set',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      setState(() {
        saveButtonClicked = false;
        _messageController.clear();
      });
    }).catchError((error) {
      print("Failed to send message: $error");
    });
  }

  void checkWinner() {
    _roomRef.child(widget.roomId).onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null &&
          event.snapshot.value is Map<String, dynamic>) {
        final Map<String, dynamic> snapshotValue =
            event.snapshot.value as Map<String, dynamic>;
        String? inputString = snapshotValue['winner'];
        if (inputString != null) {
          List<String> parts = inputString.split(':');
          if (parts.length == 2) {
            String sender = parts[0].trim();
            String winner = parts[1].trim();

            if (sender == 'player1' && widget.playerId != 'player1') {
              _messageListener.cancel();
              setState(() {
                saveButtonClicked = false;
              });
            }
            if (sender == 'player2' && widget.playerId != 'player2') {
              _messageListener.cancel();
              setState(() {
                saveButtonClicked = false;
              });
            }
            setState(() {
              refreshButtonVisible = true;
              save_clear = "Save";
            });
            String? winnerName = snapshotValue[sender];
            WinnerScreen(
              context,
              '$winnerName',
              widget.roomId,
              widget.playerId,
              widget.username,
            );
            clearClickedBoxIndices();
          } else {
            print("Invalid input format");
          }
        }
      }
    });
  }

  int getNumberAtIndex(int index) {
    if (index >= 0 && index < matrixNumbers.length) {
      return matrixNumbers[index];
    } else {
      return -1;
    }
  }

  void onBoxClicked(int index) {
    if (saveButtonClicked) {
      if (!clickedBoxIndices.contains(index)) {
        setState(() {
          clickedBoxIndices.add(index);
        });
        int numberInBox = getNumberAtIndex(index);

        _sendMessage("$numberInBox");
        checkCombinations();
        checkWinner();
      }
    }
  }

  void _listenForMessages(String roomId, String currentPlayerId) {
    _chatMessageListener?.cancel();
    _chatMessageListener =
        _roomRef.child(widget.roomId).onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null &&
          event.snapshot.value is Map<String, dynamic>) {
        final Map<String, dynamic> snapshotValue =
            event.snapshot.value as Map<String, dynamic>;
        String? inputString = snapshotValue['ChatMessage'];
        if (inputString != null) {
          List<String> parts = inputString.split(':');
          if (parts.length == 2) {
            String sender = parts[0].trim();
            String message = parts[1].trim();

            if (sender != currentPlayerId) {
              Fluttertoast.showToast(
                backgroundColor: Colors.blueGrey,
                textColor: Colors.black,
                msg: message,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
              );
            }
          }
        }
      }
    });
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
        declareWinner();
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

  final snackBar = const SnackBar(
    content: Text('It Is Your Turn..!'),
    duration: Duration(seconds: 2),
  );

  void _listenToMessage() {
    _messageListener =
        _roomRef.child(widget.roomId).onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null &&
          event.snapshot.value is Map<String, dynamic>) {
        final Map<String, dynamic> snapshotValue =
            event.snapshot.value as Map<String, dynamic>;
        String? inputString = snapshotValue['message'];
        if (inputString != null) {
          List<String> parts = inputString.split(':');
          if (parts.length == 2) {
            String sender = parts[0].trim();
            String message = parts[1].trim();

            if (sender.contains('player1') && widget.playerId != 'player2') {
              setState(() {
                saveButtonClicked = false;
              });
            } else if (sender.contains('player2') &&
                widget.playerId != 'player2') {
              Fluttertoast.showToast(
                msg: 'received: $message',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
              setState(() {
                saveButtonClicked = true;
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              });
            } else if (sender.contains('player2') &&
                widget.playerId != 'player1') {
              setState(() {
                saveButtonClicked = false;
              });
            } else if (sender.contains('player1') &&
                widget.playerId != 'player1') {
              Fluttertoast.showToast(
                msg: 'received: $message',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
              setState(() {
                saveButtonClicked = true;
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              });
            } else {
              saveButtonClicked = false;
            }

            int num = findIndexForNumber(message);
            if (!clickedBoxIndices.contains(num)) {
              setState(() {
                clickedBoxIndices.add(num);
              });
              checkCombinations();
              checkWinner();
            }
          } else {
            print("Invalid input format");
          }
        }
      }
    });
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
                      onTap: () {
                        onBoxClicked(index);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(2.0),
                        color: isClicked ? Colors.black : Colors.blueGrey,
                        child: Center(
                          child: Text(
                            matrixNumbers[index].toString(),
                            style: const TextStyle(color: Colors.white),
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
                        onPressed: () {
                          generateMatrixNumbers();
                          clearClickedBoxIndices();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          fixedSize: const Size(100, 40),
                        ),
                        child: const Text(
                          'Refresh',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          refreshButtonVisible = false;
                          appBarText = "";
                          save_clear = "Clear";
                          if (widget.playerId == 'player1') {
                            saveButtonClicked = true;
                            Fluttertoast.showToast(
                              msg: "It is your turn",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                            );
                          }
                        });
                        _listenToMessage();
                        clearClickedBoxIndices();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          fixedSize: const Size(100, 40)),
                      child: Text(
                        save_clear,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            right: 0.0,
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () {
                _messageListener.cancel();
                ChatScreen(
                  context,
                  widget.roomId,
                  widget.playerId,
                  widget.username,
                );
                _listenToMessage();
              },
              child: const Icon(Icons.chat),
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 30.0,
            child: // Adjust the spacing between icons
                FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () {
                ShowResultScreen(context);
              },
              child: const Icon(Icons.date_range_sharp),
            ),
          ),
          Positioned(
            top: 16.0,
            right: 0.0,
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () {
                _exitChat();
              },
              child: const Icon(Icons.exit_to_app_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
