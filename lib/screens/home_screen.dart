import 'package:bingo_1/screens/offline_screen.dart';
import 'package:flutter/material.dart';
import '../screens/create_room_screen.dart';
import '../screens/join_room_screen.dart';

class HomeScreen extends StatelessWidget {

void createRoom(BuildContext context) {
    Navigator.pushNamed(context, CreateRoomScreen.routeName);
  }

  void joinRoom(BuildContext context) {
    Navigator.pushNamed(context, JoinRoomScreen.routeName);
  }
void offlineScreen(BuildContext context) {
    Navigator.pushNamed(context, ScreenOffline.routeName);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Bingo Home'),
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
                'Welcome to Bingo!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: ()  => createRoom(context),
                icon: Icon(Icons.add),
                label: Text('Create Room'),
              ),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => joinRoom(context),
                icon: Icon(Icons.login),
                label: Text('Join Room'),
              ),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: ()=> offlineScreen(context),
                icon: Icon(Icons.videogame_asset),
                label: Text('Offline Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}