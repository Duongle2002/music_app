import 'package:flutter/material.dart';
import 'package:music_app/main.dart';
import 'package:provider/provider.dart';
import 'song.dart';
import 'song_provider.dart';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi fetchSongs khi màn hình khởi tạo
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
            body: Center(child: Text('Error: ${songProvider.error}')),
          );
        } else if (songProvider.songs.isEmpty) {
          return Scaffold(
            body: Center(child: Text('No songs found')),
          );
        }

        final songs = songProvider.songs;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Your Library', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(icon: Icon(Icons.search), onPressed: () {}),
              IconButton(icon: Icon(Icons.add), onPressed: () {}),
            ],
          ),
          body: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: 'Playlists'),
                    Tab(text: 'Artists'),
                    Tab(text: 'Albums'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      ListView(
                        padding: EdgeInsets.all(16),
                        children: songs.map((song) => ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            color: Colors.white, // Placeholder cho ảnh
                          ),
                          title: Text(song.title),
                          subtitle: Text(song.artist),
                          onTap: () {
                            Navigator.pushNamed(context, '/player');
                            Provider.of<AudioPlayerProvider>(context, listen: false).playSong(song);
                          },
                        )).toList(),
                      ),
                      ListView(
                        padding: EdgeInsets.all(16),
                        children: songs.map((song) => ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            color: Colors.white, // Placeholder cho ảnh
                          ),
                          title: Text(song.artist),
                          onTap: () {
                            Navigator.pushNamed(context, '/player');
                            Provider.of<AudioPlayerProvider>(context, listen: false).playSong(song);
                          },
                        )).toList(),
                      ),
                      ListView(
                        padding: EdgeInsets.all(16),
                        children: songs.map((song) => ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            color: Colors.white, // Placeholder cho ảnh
                          ),
                          title: Text(song.album),
                          subtitle: Text(song.artist),
                          onTap: () {
                            Navigator.pushNamed(context, '/player');
                            Provider.of<AudioPlayerProvider>(context, listen: false).playSong(song);
                          },
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Your Library'),
            ],
            currentIndex: 2,
            onTap: (index) {
              if (index == 0) Navigator.pushNamed(context, '/home');
              if (index == 1) Navigator.pushNamed(context, '/search');
            },
          ),
        );
      },
    );
  }
}