import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'mini_player.dart';
import 'playlist.dart';
import 'song.dart';
import 'song_tile.dart';
import 'main.dart';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final PlaylistManager _playlistManager = PlaylistManager();
  List<Playlist> _playlists = [];
  final TextEditingController _playlistNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final playlists = await _playlistManager.getPlaylists();
    setState(() {
      _playlists = playlists;
    });
  }

  Future<void> _createPlaylist() async {
    if (_playlistNameController.text.isNotEmpty) {
      await _playlistManager.addPlaylist(_playlistNameController.text);
      _playlistNameController.clear();
      await _loadPlaylists();
    }
  }

  Future<void> _addSongToPlaylist(String playlistName, Song song) async {
    await _playlistManager.addSongToPlaylist(playlistName, song);
    await _loadPlaylists();
  }

  Future<void> _removeSongFromPlaylist(String playlistName, Song song) async {
    await _playlistManager.removeSongFromPlaylist(playlistName, song);
    await _loadPlaylists();
  }

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Library'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _playlistNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter playlist name',
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _createPlaylist,
                  child: Text('Create'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _playlists.length,
                itemBuilder: (context, index) {
                  final playlist = _playlists[index];
                  return ExpansionTile(
                    title: Text(playlist.name, style: Theme.of(context).textTheme.headlineMedium),
                    children: [
                      if (playlist.songs.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('No songs in this playlist', style: Theme.of(context).textTheme.bodyMedium),
                        )
                      else
                        ...playlist.songs.map((song) => ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: song.coverUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey,
                                child: Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey,
                                child: Icon(Icons.broken_image, color: Colors.white),
                              ),
                            ),
                          ),
                          title: Text(song.title, style: Theme.of(context).textTheme.bodyLarge),
                          subtitle: Text(song.artist, style: Theme.of(context).textTheme.bodyMedium),
                          trailing: IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _removeSongFromPlaylist(playlist.name, song),
                          ),
                          onTap: () {
                            Provider.of<AudioPlayerProvider>(context, listen: false).playSong(song);
                            Navigator.pushNamed(context, '/player');
                          },
                        )),
                    ],
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