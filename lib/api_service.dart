import 'dart:convert';
import 'package:http/http.dart' as http;
import 'song.dart';

class ApiService {
  // Lấy danh sách bài hát mặc định từ Apple Music API
  Future<List<Song>> fetchSongs() async {
    final response = await http.get(
      Uri.parse('https://itunes.apple.com/search?term=The+Beatles&media=music&entity=song&limit=20'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['results'] as List;
      return tracks.map((track) {
        return Song(
          id: track['trackId'] ?? track['id'].hashCode,
          title: track['trackName'] ?? 'Unknown Title',
          artist: track['artistName'] ?? 'Unknown Artist',
          album: track['collectionName'] ?? 'Unknown Album',
          duration: track['trackTimeMillis'] != null ? (track['trackTimeMillis'] ~/ 1000) : 30,
          url: track['previewUrl'] ?? 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
          coverUrl: track['artworkUrl100'] ?? 'https://via.placeholder.com/150',
        );
      }).toList();
    } else {
      throw Exception('Failed to load songs: ${response.body}');
    }
  }

  // Tìm kiếm bài hát theo từ khóa
  Future<List<Song>> searchSongs(String query) async {
    final response = await http.get(
      Uri.parse('https://itunes.apple.com/search?term=${Uri.encodeQueryComponent(query)}&media=music&entity=song&limit=10'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['results'] as List;
      return tracks.map((track) {
        return Song(
          id: track['trackId'] ?? track['id'].hashCode,
          title: track['trackName'] ?? 'Unknown Title',
          artist: track['artistName'] ?? 'Unknown Artist',
          album: track['collectionName'] ?? 'Unknown Album',
          duration: track['trackTimeMillis'] != null ? (track['trackTimeMillis'] ~/ 1000) : 30,
          url: track['previewUrl'] ?? 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
          coverUrl: track['artworkUrl100'] ?? 'https://via.placeholder.com/150',
        );
      }).toList();
    } else {
      throw Exception('Failed to load songs: ${response.body}');
    }
  }
}