import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'song.dart';
import 'song_provider.dart';
import 'song_tile.dart';
import 'mini_player.dart';

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
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Artists, songs, or albums',
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 20),
            Expanded(
              child: Consumer<SongProvider>(
                builder: (context, songProvider, child) {
                  if (songProvider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (songProvider.error != null) {
                    return Center(child: Text('Error: ${songProvider.error}', style: Theme.of(context).textTheme.bodyLarge));
                  } else if (_searchQuery.isEmpty) {
                    return Center(child: Text('Enter a search term to find songs', style: Theme.of(context).textTheme.bodyLarge));
                  } else if (songProvider.songs.isEmpty) {
                    return Center(child: Text('No songs found', style: Theme.of(context).textTheme.bodyLarge));
                  }

                  final songs = songProvider.songs;
                  return ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return SongTile(song: song, isHorizontal: false);
                    },
                  );
                },
              ),
            ),
          ],
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
        ],
      ),
    );
  }
}