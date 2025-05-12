import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'song.dart';

class OfflineManager {
  Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _getLocalFile(String fileName) async {
    final path = await _getLocalPath();
    return File('$path/$fileName');
  }

  Future<void> downloadSong(Song song) async {
    try {
      final response = await http.get(Uri.parse(song.url));
      if (response.statusCode == 200) {
        final file = await _getLocalFile('${song.id}.mp3');
        await file.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception('Failed to download song: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading song: $e');
    }
  }

  Future<bool> isSongDownloaded(Song song) async {
    final file = await _getLocalFile('${song.id}.mp3');
    return file.exists();
  }

  Future<String?> getLocalSongPath(Song song) async {
    final file = await _getLocalFile('${song.id}.mp3');
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  Future<void> deleteSong(Song song) async {
    final file = await _getLocalFile('${song.id}.mp3');
    if (await file.exists()) {
      await file.delete();
    }
  }
}