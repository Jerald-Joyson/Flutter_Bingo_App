import 'dart:math';
import 'package:bingo_1/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../widgets/custom_text.dart';

class ScreenOffline extends StatefulWidget {

  static String routeName = '/offline-screen';
  @override
  _ScreenOfflineState createState() => _ScreenOfflineState();
}

class _ScreenOfflineState extends State<ScreenOffline> {
  List<int> matrixNumbers = [];
  bool refreshButtonVisible = true;
  bool saveButtonClicked = false;
  List<int> clickedBoxIndices = [];
  String appBarText = "";
  String saveClearText = "Save";

  @override
  void initState() {
    super.initState();
    generateMatrixNumbers();
  }

  void generateMatrixNumbers() {
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
      saveButtonClicked = true;
      appBarText = "";
      saveClearText = "Clear";
    });
    clearClickedBoxIndices();
  }

  void bingo() {
    setState(() {
      refreshButtonVisible = true;
      saveButtonClicked = false;
      saveClearText = "Save";
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

        Fluttertoast.showToast(
          msg: "Clicked Element is: $numberInBox",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
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

    setState(() {
      appBarText = letter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double gridSize = size.width < size.height ? size.width * 0.85 : size.height * 0.55;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Offline Bingo",
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
                          color: isClicked ? Colors.blueAccent : Colors.blueGrey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: isClicked
                              ? Border.all(color: Colors.blueAccent, width: 2)
                              : Border.all(color: Colors.blueGrey[300]!, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            matrixNumbers[index].toString(),
                            style: TextStyle(
                              color: isClicked ? Colors.white : Colors.blueGrey[900],
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
                        onPressed: refreshMatrix,
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
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: saveMatrix,
                      icon: Icon(
                        saveClearText == "Save" ? Icons.save : Icons.clear,
                        color: Colors.white,
                      ),
                      label: Text(
                        saveClearText,
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
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}