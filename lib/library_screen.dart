import 'package:flutter/material.dart';
import 'mini_player.dart';

class LibraryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Library'),
      ),
      body: Center(
        child: Text(
          'Library Screen',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(),
          BottomNavigationBar(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            currentIndex: 2,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Your Library'),
            ],
            onTap: (index) {
              if (index == 0) Navigator.pushNamed(context, '/home');
              if (index == 1) Navigator.pushNamed(context, '/search');
            },
          ),
        ],
      ),
    );
  }
}