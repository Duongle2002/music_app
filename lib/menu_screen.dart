import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        final song = audioProvider.currentSong;
        if (song == null) {
          return Scaffold(
            body: Center(child: Text('No song selected')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  color: Colors.white, // Placeholder cho ảnh
                ),
                title: Text(song.title),
                subtitle: Text(song.artist),
              ),
              ListTile(
                leading: Icon(Icons.favorite_border),
                title: Text('Like'),
              ),
              ListTile(
                leading: Icon(Icons.download),
                title: Text('Download'),
              ),
              ListTile(
                leading: Icon(Icons.add),
                title: Text('Add to playlist'),
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text('Share'),
              ),
              ListTile(
                leading: Icon(Icons.album),
                title: Text('Go to album'),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Go to artist'),
              ),
            ],
          ),
        );
      },
    );
  }
}