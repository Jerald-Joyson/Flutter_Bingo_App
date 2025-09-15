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

  StreamSubscription? _messageListener;
  StreamSubscription? _winnerListener; // NEW
  List<int> matrixNumbers = [];
  bool refreshButtonVisible = true;
  bool saveButtonClicked = false;
  List<int> clickedBoxIndices = [];
  String appBarText = "";
  String save_clear = "Save";
  StreamSubscription? _chatBadgeListener;
  bool showChatDot = false;
  String? _lastSeenChatKey;

  late final DatabaseReference _roomRef =
      FirebaseDatabase.instance.reference().child('rooms');

  @override
  void initState() {
    super.initState();
    generateMatrixNumbers();
    _listenToMessage();
    _listenToWinner();
    _initChatBadge(); // NEW
  }

  @override
  void dispose() {
    _messageListener?.cancel();
    _winnerListener?.cancel();
    _chatBadgeListener?.cancel(); // NEW
    super.dispose();
  }

  void _sendMove(int number) {
    final sender = widget.playerId;
    _roomRef.child(widget.roomId).update({
      'message': '$sender:$number',
    });
  }
Future<void> _initChatBadge() async {
    final chatRef =
        _roomRef.child(widget.roomId).child('chatHistory');

    // Establish baseline (current last message key) to avoid showing a dot for history
    try {
      final lastSnap = await chatRef.limitToLast(1).get();
      final raw = lastSnap.value;
      if (raw is Map && raw.isNotEmpty) {
        _lastSeenChatKey = (raw.keys.toList()..sort()).last.toString();
      }
    } catch (_) {}

    _chatBadgeListener = chatRef.onChildAdded.listen((DatabaseEvent event) {
      final key = event.snapshot.key;
      if (key == null) return;

      final value = event.snapshot.value;
      String sender = '';
      if (value is Map && value['sender'] != null) {
        sender = value['sender'].toString();
      }

      // If this is a new message after baseline and it's from the other player -> show dot
      if (_lastSeenChatKey != null && key != _lastSeenChatKey) {
        if (sender != widget.username) {
          if (mounted) {
            setState(() {
              showChatDot = true;
            });
          }
        }
      }

      // Advance baseline to the latest seen key
      _lastSeenChatKey = key;
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

  Future<String> _myDisplayName() async {
    final snap = await _roomRef.child(widget.roomId).get();
    if (snap.value is Map) {
      final data = snap.value as Map;
      if (widget.playerId == 'player1') {
        return data['player1Name']?.toString() ?? widget.username;
      } else {
        return data['player2Name']?.toString() ?? widget.username;
      }
    }
    return widget.username;
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
    var numbers = List.generate(25, (index) => index + 1);
    numbers.shuffle();
    setState(() {
      matrixNumbers = numbers;
    });
  }

  void clearClickedBoxIndices() {
    _roomRef.child(widget.roomId).update({'message': ''});
    setState(() {
      clickedBoxIndices.clear();
      appBarText = "";
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
    if (saveButtonClicked && !clickedBoxIndices.contains(index)) {
      setState(() {
        clickedBoxIndices.add(index);
      });
      final numberInBox = getNumberAtIndex(index);
      _sendMove(numberInBox); // CHANGED: was _sendMessage
      checkCombinations();
      // checkWinner(); // winner is handled via _listenToWinner
    }
  }

  final snackBar = const SnackBar(
    content: Text('It Is Your Turn..!'),
    duration: Duration(seconds: 2),
  );

  void _listenToMessage() {
    _messageListener?.cancel();
    _messageListener =
        _roomRef.child(widget.roomId).onValue.listen((DatabaseEvent event) {
      final value = event.snapshot.value;
      if (value is Map) {
        final inputString = value['message']?.toString();
        if (inputString != null && inputString.contains(':')) {
          final parts = inputString.split(':');
          if (parts.length == 2) {
            final sender = parts[0].trim();
            final message = parts[1].trim();

            // Enable my turn when the other player moved; disable otherwise
            if (sender != widget.playerId) {
              setState(() {
                saveButtonClicked = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              Fluttertoast.showToast(
                msg: 'received: $message',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
            } else {
              setState(() {
                saveButtonClicked = false;
              });
            }

            final numIndex = findIndexForNumber(message);
            if (numIndex >= 0 && !clickedBoxIndices.contains(numIndex)) {
              setState(() {
                clickedBoxIndices.add(numIndex);
              });
              checkCombinations();
            }
          } else {
            print("Invalid input format");
          }
        }
      }
    });
  }

  void _listenToWinner() {
    _winnerListener?.cancel();
    _winnerListener = _roomRef
        .child(widget.roomId)
        .child('winner')
        .onValue
        .listen((DatabaseEvent event) async {
      final winnerValue = event.snapshot.value;
      if (winnerValue == null) return;

      final roomSnap = await _roomRef.child(widget.roomId).get();
      String winnerName = 'Winner';
      if (roomSnap.value is Map) {
        final m = roomSnap.value as Map;
        winnerName = m['winnerName']?.toString() ?? winnerName;
      }

      setState(() {
        refreshButtonVisible = true;
        save_clear = "Save";
        saveButtonClicked = false;
      });

      WinnerScreen(
        context,
        winnerName,
        widget.roomId,
        widget.playerId,
        widget.username,
      );
    });
  }

  Future<void> declareWinner() async {
    try {
      // Avoid double declare
      final winnerSet =
          await _roomRef.child(widget.roomId).child('winner').get();
      if (winnerSet.value != null) return;

      final winnerId = widget.playerId;

      // Resolve display name from room (player1Name/player2Name)
      final snap = await _roomRef.child(widget.roomId).get();
      String winnerName = widget.username;
      if (snap.value is Map) {
        final data = snap.value as Map;
        if (winnerId == 'player1') {
          winnerName = data['player1Name']?.toString() ?? winnerName;
        } else {
          winnerName = data['player2Name']?.toString() ?? winnerName;
        }
      }

      // Increment wins count: wins/player1 or wins/player2
      final winsRef =
          _roomRef.child(widget.roomId).child('wins').child(winnerId);
      final winSnap = await winsRef.get();
      int current = 0;
      final v = winSnap.value;
      if (v is int) current = v;
      if (v is String) current = int.tryParse(v) ?? 0;
      await winsRef.set(current + 1);

      await _roomRef.child(widget.roomId).update({
        'winner': '$winnerId:winner',
        'winnerId': winnerId,
        'winnerName': winnerName,
        'winnerAt': ServerValue.timestamp,
      });

      await _messageListener?.cancel();
      Fluttertoast.showToast(
        msg: 'Winner: $winnerName',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      setState(() {
        saveButtonClicked = false;
      });
    } catch (e) {
      print("Failed to declare winner: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double gridSize =
        size.width < size.height ? size.width * 0.85 : size.height * 0.55;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Online Bingo",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[900],
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: appBarText.isNotEmpty
                    ? CustomText(
                        key: ValueKey(appBarText),
                        text: appBarText,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.blueGrey,
                          )
                        ],
                      )
                    : SizedBox(height: 28),
              ),
              SizedBox(height: 20),
              Container(
                width: gridSize,
                height: gridSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.15),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: matrixNumbers.length,
                  itemBuilder: (context, index) {
                    bool isClicked = clickedBoxIndices.contains(index);
                    return GestureDetector(
                      onTap: () => onBoxClicked(index),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isClicked
                              ? Colors.blueAccent
                              : Colors.blueGrey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: isClicked
                              ? Border.all(color: Colors.blueAccent, width: 2)
                              : Border.all(
                                  color: Colors.blueGrey[300]!, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            matrixNumbers[index].toString(),
                            style: TextStyle(
                              color: isClicked
                                  ? Colors.white
                                  : Colors.blueGrey[900],
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Visibility(
                      visible: refreshButtonVisible,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          generateMatrixNumbers();
                          clearClickedBoxIndices();
                        },
                        icon: Icon(Icons.refresh, color: Colors.white),
                        label: Text(
                          'Refresh',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
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
                      icon: Icon(
                        save_clear == "Save" ? Icons.save : Icons.clear,
                        color: Colors.white,
                      ),
                      label: Text(
                        save_clear,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                saveButtonClicked
                    ? "Tap boxes to mark your Bingo numbers!"
                    : "Press 'Save' to start marking numbers.",
                style: TextStyle(
                  color: Colors.blueGrey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            heroTag: 'chat',
            onPressed: () async {
              // Clear the badge and pause game move listener while chat dialog is open
              setState(() => showChatDot = false); // NEW
              await _messageListener?.cancel();
              await ChatScreen(
                context,
                widget.roomId,
                widget.playerId,
                widget.username,
              );
              _listenToMessage(); // resume after dialog closes
            },
            // NEW: Stack to render a green dot badge on top-right
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.chat, color: Colors.white),
                if (showChatDot)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            backgroundColor: Colors.blueGrey[700],
            heroTag: 'result',
            onPressed: () {
              ShowResultScreen(context, widget.roomId);
            },
            child: Icon(Icons.date_range_sharp, color: Colors.white),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            backgroundColor: Colors.redAccent,
            heroTag: 'exit',
            onPressed: () {
              _exitChat();
            },
            child: Icon(Icons.exit_to_app_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
