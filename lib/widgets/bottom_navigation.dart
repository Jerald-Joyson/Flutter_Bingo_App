// import 'package:flutter/material.dart';
// import '../screens/home_screen.dart';

// class BottomNavigation extends StatelessWidget {
//   const BottomNavigation({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//       valueListenable: HomeScreen.selectedIndexNotifier,
//       builder: (BuildContext context, int updatedIndex, Widget? _) {
//         return BottomNavigationBar(
//             selectedItemColor: Colors.purple,
//             unselectedItemColor: Colors.grey,
//             currentIndex: updatedIndex,
//             onTap: (newIndex) {
//               HomeScreen.selectedIndexNotifier.value = newIndex;
//             },
//             items: const [
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.wifi_off),
//                 label: 'Offline',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.wifi),
//                 label: 'Online',
//               ),
//             ]);
//       },
//     );
//   }
// }
