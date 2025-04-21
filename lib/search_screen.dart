import 'package:flutter/material.dart';
import 'package:music_app/main.dart';
import 'package:provider/provider.dart';
import 'song.dart';
import 'song_provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi trong TextField để cập nhật query
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
      if (_searchQuery.isNotEmpty) {
        Provider.of<SongProvider>(context, listen: false).searchSongs(_searchQuery);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Search', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Artists, songs, or albums',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Consumer<SongProvider>(
                builder: (context, songProvider, child) {
                  if (songProvider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (songProvider.error != null) {
                    return Center(child: Text('Error: ${songProvider.error}', style: TextStyle(color: Colors.white)));
                  } else if (_searchQuery.isEmpty) {
                    return Center(child: Text('Enter a search term to find songs', style: TextStyle(color: Colors.white)));
                  } else if (songProvider.songs.isEmpty) {
                    return Center(child: Text('No songs found', style: TextStyle(color: Colors.white)));
                  }

                  final songs = songProvider.songs;
                  return ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            song.coverUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey,
                                child: Icon(Icons.broken_image, color: Colors.white),
                              );
                            },
                          ),
                        ),
                        title: Text(song.title, style: TextStyle(color: Colors.white)),
                        subtitle: Text('${song.artist} • ${song.album}', style: TextStyle(color: Colors.grey)),
                        onTap: () {
                          Navigator.pushNamed(context, '/player');
                          Provider.of<AudioPlayerProvider>(context, listen: false).playSong(song);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Your Library'),
        ],
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/home');
          if (index == 2) Navigator.pushNamed(context, '/library');
        },
      ),
    );
  }
}