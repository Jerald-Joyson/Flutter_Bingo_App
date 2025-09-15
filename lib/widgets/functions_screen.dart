import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'custom_text.dart';

void WinnerScreen(
  BuildContext context,
  String winnerName,
  String roomId,
  String playerId,
  String username,
) {
  final _roomRef = FirebaseDatabase.instance.reference().child('rooms');
  final size = MediaQuery.of(context).size;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: size.width > 520 ? 520 : size.width - 32,
          height: 240,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Round Result',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$winnerName won this round!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  await _roomRef.child(roomId).update({
                    'winner': null,
                    'winnerId': null,
                    'message': '',
                  });
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ...existing code...
Future<void> ChatScreen(
  BuildContext context,
  String roomId,
  String playerId,
  String username,
) {
  final size = MediaQuery.of(context).size;
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: size.width > 520 ? 520 : size.width - 32,
          height: 420,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Room Chat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(child: _ChatHistorySection(roomId: roomId, username: username)),
              const SizedBox(height: 8),
              _ChatInputSection(roomId: roomId, username: username),
            ],
          ),
        ),
      );
    },
  );
}

class _ChatHistorySection extends StatelessWidget {
  final String roomId;
  final String username;
  const _ChatHistorySection({required this.roomId, required this.username});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference chatRef =
        FirebaseDatabase.instance.reference().child('rooms/$roomId/chatHistory');

    return StreamBuilder<DatabaseEvent>(
      stream: chatRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final messages = data.values.toList()
            ..sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index] as Map<dynamic, dynamic>;
              final isMe = msg['sender'] == username;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blueAccent : Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${msg['sender']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isMe ? Colors.white : Colors.blueGrey[700],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${msg['message']}',
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.blueGrey[900],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: Text("No messages yet."));
      },
    );
  }
}

class _ChatInputSection extends StatefulWidget {
  final String roomId;
  final String username;
  const _ChatInputSection({required this.roomId, required this.username});

  @override
  State<_ChatInputSection> createState() => _ChatInputSectionState();
}

class _ChatInputSectionState extends State<_ChatInputSection> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    final message = _controller.text.trim();
    if (message.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      final chatRef = FirebaseDatabase.instance
          .reference()
          .child('rooms/${widget.roomId}/chatHistory');
      final newMessage = {
        'sender': widget.username,
        'message': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await chatRef.push().set(newMessage);
      _controller.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Type a message...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onSubmitted: (_) => _send(),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _send,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          child: _sending
              ? const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send, color: Colors.white),
        ),
      ],
    );
  }
}

void ShowResultScreen(
  BuildContext context,
  String roomId,
) {
  final size = MediaQuery.of(context).size;
  final roomRef =
      FirebaseDatabase.instance.reference().child('rooms').child(roomId);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: size.width > 520 ? 520 : size.width - 32,
          height: 240,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: FutureBuilder<DataSnapshot>(
            future: roomRef.get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snapshot.data?.value;
              Map wins = {};
              String p1Name = 'Player 1';
              String p2Name = 'Player 2';

              if (data is Map) {
                if (data['player1Name'] != null) p1Name = data['player1Name'].toString();
                if (data['player2Name'] != null) p2Name = data['player2Name'].toString();
                if (data['wins'] is Map) wins = data['wins'] as Map;
              }

              int toInt(dynamic v) {
                if (v is int) return v;
                if (v is String) return int.tryParse(v) ?? 0;
                return 0;
              }

              final p1Wins = toInt(wins['player1']);
              final p2Wins = toInt(wins['player2']);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Wins Summary',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p1Name, style: const TextStyle(fontSize: 16)),
                      Text('$p1Wins', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p2Name, style: const TextStyle(fontSize: 16)),
                      Text('$p2Wins', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}