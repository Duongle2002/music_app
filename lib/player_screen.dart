import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class PlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        final currentSong = audioProvider.currentSong;
        if (currentSong == null) {
          return Scaffold(
            body: Center(child: Text('No song selected', style: Theme.of(context).textTheme.bodyLarge)),
          );
        }

        final duration = audioProvider.audioPlayer.duration ?? Duration(seconds: 30);
        final position = audioProvider.position;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: audioProvider.audioPlayer.processingState == ProcessingState.buffering
              ? Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'song-${currentSong.id}', // This is fine as there's only one PlayerScreen
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: currentSong.coverUrl,
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 300,
                        height: 300,
                        color: Colors.grey,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 300,
                        height: 300,
                        color: Colors.grey,
                        child: Icon(Icons.broken_image, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  currentSong.title,
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                Text(
                  currentSong.artist,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 20),
                Slider(
                  value: position.inSeconds.toDouble(),
                  max: duration.inSeconds.toDouble(),
                  onChanged: (value) async {
                    try {
                      await audioProvider.audioPlayer.seek(Duration(seconds: value.toInt()));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Không thể thay đổi vị trí bài hát')),
                      );
                    }
                  },
                  activeColor: Theme.of(context).primaryColor,
                  inactiveColor: Theme.of(context).hintColor,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      _formatDuration(duration),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.shuffle,
                        size: 30,
                        color: audioProvider.isShuffling ? Colors.green : Colors.white,
                      ),
                      onPressed: audioProvider.toggleShuffle,
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_previous, size: 40),
                      onPressed: audioProvider.playPrevious,
                    ),
                    IconButton(
                      icon: Icon(
                        audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 40,
                      ),
                      onPressed: audioProvider.togglePlayPause,
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next, size: 40),
                      onPressed: audioProvider.playNext,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.repeat,
                        size: 30,
                        color: audioProvider.isRepeating ? Colors.green : Colors.white,
                      ),
                      onPressed: audioProvider.toggleRepeat,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}