import 'package:flutter/material.dart';
import 'package:music_app/main.dart';
import 'package:provider/provider.dart';
import 'song.dart';
import 'song_provider.dart';
import 'song_tile.dart';
import 'mini_player.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SongProvider>(context, listen: false).fetchSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SongProvider>(
      builder: (context, songProvider, child) {
        if (songProvider.isLoading) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (songProvider.error != null) {
          return Scaffold(
            body: Center(child: Text('Error: ${songProvider.error}', style: Theme.of(context).textTheme.bodyLarge)),
          );
        } else if (songProvider.songs.isEmpty) {
          return Scaffold(
            body: Center(child: Text('No songs found', style: Theme.of(context).textTheme.bodyLarge)),
          );
        }

        final songs = songProvider.songs;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<AudioPlayerProvider>(context, listen: false).setSongs(songs);
        });

        return Scaffold(
          appBar: AppBar(
            title: Text('Good evening'),
            actions: [
              IconButton(
                icon: Icon(Icons.person),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    children: [
                      Chip(
                        label: Text('Recently played'),
                        backgroundColor: Colors.grey[800],
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      Chip(
                        label: Text('Your top mixes'),
                        backgroundColor: Colors.grey[800],
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      Chip(
                        label: Text('Based on your recent listening'),
                        backgroundColor: Colors.grey[800],
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Recently played', style: Theme.of(context).textTheme.headlineLarge),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SongTile(song: song, isHorizontal: true),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Your top mixes', style: Theme.of(context).textTheme.headlineLarge),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SongTile(song: song, isHorizontal: true),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Based on your recent listening', style: Theme.of(context).textTheme.headlineLarge),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SongTile(song: song, isHorizontal: true),
                        );
                      },
                    ),
                  ),
                ],
              ),
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
                items: [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                  BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Your Library'),
                ],
                onTap: (index) {
                  if (index == 1) Navigator.pushNamed(context, '/search');
                  if (index == 2) Navigator.pushNamed(context, '/library');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}