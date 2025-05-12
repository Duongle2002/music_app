import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'song.dart';

class MiniPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        final currentSong = audioProvider.currentSong;
        if (currentSong == null) {
          return SizedBox.shrink();
        }

        final duration = audioProvider.audioPlayer.duration ?? Duration(seconds: 30);
        final position = audioProvider.position;

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/player');
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[900],
            child: Column(
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'song-${currentSong.id}', // This is fine as there's only one MiniPlayer
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: currentSong.coverUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 40,
                            height: 40,
                            color: Colors.grey,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 40,
                            height: 40,
                            color: Colors.grey,
                            child: Icon(Icons.broken_image, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentSong.title,
                            style: Theme.of(context).textTheme.bodyLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            currentSong.artist,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        audioProvider.togglePlayPause();
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.skip_next,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        audioProvider.playNext();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () {
                        audioProvider.stopAndClear();
                      },
                    ),
                  ],
                ),
                LinearProgressIndicator(
                  value: duration.inSeconds > 0 ? position.inSeconds / duration.inSeconds : 0,
                  backgroundColor: Colors.grey[700],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}