import 'package:flutter/material.dart';
import 'song.dart';
import 'main.dart';
import 'package:provider/provider.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isHorizontal;

  const SongTile({required this.song, this.isHorizontal = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/player');
        Provider.of<AudioPlayerProvider>(context, listen: false).playSong(song);
      },
      child: isHorizontal
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'song-${song.id}',
            child: ClipRRect(
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
        ),
        title: Text(song.title, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Text('${song.artist} • ${song.album}', style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}