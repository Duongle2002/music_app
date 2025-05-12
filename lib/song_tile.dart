import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'song.dart';
import 'main.dart';
import 'package:provider/provider.dart';
import 'playlist.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isHorizontal;

  const SongTile({required this.song, this.isHorizontal = false});

  Future<void> _showAddToPlaylistDialog(BuildContext context) async {
    final playlistManager = PlaylistManager();
    final playlists = await playlistManager.getPlaylists();
    if (playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No playlists available. Create one in Library.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add to Playlist'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return ListTile(
                  title: Text(playlist.name),
                  onTap: () async {
                    try {
                      await playlistManager.addSongToPlaylist(playlist.name, song);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added to ${playlist.name}')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi khi thêm bài hát: $e')),
                      );
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        return FutureBuilder<bool>(
          future: audioProvider.isSongDownloaded(song),
          builder: (context, snapshot) {
            final isDownloaded = snapshot.data ?? false;
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/player');
                Provider.of<AudioPlayerProvider>(context, listen: false).playSong(song);
              },
              child: isHorizontal
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Hero(
                        tag: 'song-${song.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: song.coverUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey,
                              child: Icon(Icons.broken_image, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.add_circle, color: Colors.white, size: 20),
                              onPressed: () => _showAddToPlaylistDialog(context),
                            ),
                            IconButton(
                              icon: Icon(
                                isDownloaded ? Icons.delete : Icons.download,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () async {
                                if (isDownloaded) {
                                  await audioProvider.deleteSong(song);
                                } else {
                                  await audioProvider.downloadSong(song);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 100,
                    child: Text(
                      song.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      song.artist,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              )
                  : ListTile(
                leading: Hero(
                  tag: 'song-${song.id}',
                  child: ClipRRect(
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
                ),
                title: Text(song.title, style: Theme.of(context).textTheme.bodyLarge),
                subtitle: Text('${song.artist} • ${song.album}', style: Theme.of(context).textTheme.bodyMedium),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.white),
                      onPressed: () => _showAddToPlaylistDialog(context),
                    ),
                    IconButton(
                      icon: Icon(
                        isDownloaded ? Icons.delete : Icons.download,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        if (isDownloaded) {
                          await audioProvider.deleteSong(song);
                        } else {
                          await audioProvider.downloadSong(song);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}