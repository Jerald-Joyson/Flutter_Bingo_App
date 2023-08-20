import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';

class WatingLobby extends StatefulWidget {
  const WatingLobby({super.key});

  @override
  State<WatingLobby> createState() => _WatingLobbyState();
}

class _WatingLobbyState extends State<WatingLobby> {
  late TextEditingController roomIdController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    roomIdController = TextEditingController(
      text:"Room Id",
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    roomIdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
