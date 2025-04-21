import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'song.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'player_screen.dart';
import 'song_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SongProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/home',
        routes: {
          '/home': (context) => HomeScreen(),
          '/search': (context) => SearchScreen(),
          '/library': (context) => LibraryScreen(),
          '/player': (context) => PlayerScreen(),
          '/profile': (context) => ProfileScreen(),
        },
      ),
    );
  }
}

class AudioPlayerProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Song> _songs = [];
  int _currentSongIndex = 0;
  Song? _currentSong;
  bool _isPlaying = false;
  Duration _position = Duration.zero;

  AudioPlayer get audioPlayer => _audioPlayer;
  List<Song> get songs => _songs;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  int get currentSongIndex => _currentSongIndex;
  Duration get position => _position;

  AudioPlayerProvider() {
    _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });
    _audioPlayer.durationStream.listen((duration) {
      notifyListeners();
    });
  }

  void setSongs(List<Song> songs) {
    _songs = songs;
    if (_songs.isNotEmpty) {
      _currentSongIndex = 0;
      _currentSong = _songs[_currentSongIndex];
    }
    notifyListeners();
  }

  Future<void> playSong(Song song) async {
    // Dừng bài hiện tại và đặt lại trạng thái trước khi phát bài mới
    await _audioPlayer.stop();
    _position = Duration.zero; // Đặt lại vị trí phát về 0
    notifyListeners();

    // Cập nhật bài hát hiện tại
    final index = _songs.indexOf(song);
    if (index != -1) {
      _currentSongIndex = index;
      _currentSong = song;
    }

    // Phát bài mới
    try {
      await _audioPlayer.setUrl(song.url);
      await _audioPlayer.play();
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
      print('Error playing song: $e');
    }
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void playNext() {
    if (_currentSongIndex < _songs.length - 1) {
      _currentSongIndex++;
      _currentSong = _songs[_currentSongIndex];
      playSong(_currentSong!);
    }
  }

  void playPrevious() {
    if (_currentSongIndex > 0) {
      _currentSongIndex--;
      _currentSong = _songs[_currentSongIndex];
      playSong(_currentSong!);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Text('Profile Screen'),
      ),
    );
  }
}