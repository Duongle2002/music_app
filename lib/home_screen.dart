import 'package:flutter/material.dart';
import 'package:music_app/main.dart';
import 'package:provider/provider.dart';
import 'song.dart';
import 'song_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        // Di chuyển logic setSongs ra khỏi build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<AudioPlayerProvider>(context, listen: false).setSongs(songs);
        });

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Good evening', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            actions: [
              IconButton(
                icon: Icon(Icons.person, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ],
          ),
          body: Container(
            color: Colors.black, // Nền đen giống Spotify
            child: SingleChildScrollView(
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
                    Text('Recently played', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
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
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/player');
                                Provider.of<AudioPlayerProvider>(context, listen: false).playSong(song);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      song.coverUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey,
                                          child: Icon(Icons.broken_image, color: Colors.white),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    song.title,
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Your top mixes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
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
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/player');
                                Provider.of<AudioPlayerProvider>(context, listen: false).playSong(song);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      song.coverUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey,
                                          child: Icon(Icons.broken_image, color: Colors.white),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    song.album,
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Based on your recent listening', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
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
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/player');
                                Provider.of<AudioPlayerProvider>(context, listen: false).playSong(song);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      song.coverUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey,
                                          child: Icon(Icons.broken_image, color: Colors.white),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    song.artist,
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
            onTap: (index) {
              if (index == 1) Navigator.pushNamed(context, '/search');
              if (index == 2) Navigator.pushNamed(context, '/library');
            },
          ),
        );
      },
    );
  }
}