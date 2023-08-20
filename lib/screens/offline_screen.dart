import 'dart:math';
import 'package:bingo_1/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../widgets/custom_text.dart';

class ScreenOffline extends StatefulWidget {
  @override
  _ScreenOfflineState createState() => _ScreenOfflineState();
}

class _ScreenOfflineState extends State<ScreenOffline> {
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
      saveButtonClicked = true;
      appBarText = "";
      save_clear = "Clear";
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
