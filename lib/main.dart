import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'dart:math';
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
          scaffoldBackgroundColor: Colors.black,
          primaryColor: Colors.white,
          hintColor: Colors.grey,
          textTheme: TextTheme(
            headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
            bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
            bodyMedium: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
            ),
          ),
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
  bool _isShuffling = false;
  bool _isRepeating = false;

  AudioPlayer get audioPlayer => _audioPlayer;
  List<Song> get songs => _songs;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  int get currentSongIndex => _currentSongIndex;
  Duration get position => _position;
  bool get isShuffling => _isShuffling;
  bool get isRepeating => _isRepeating;

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
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        if (_isRepeating) {
          playSong(_currentSong!); // Lặp lại bài hiện tại
        } else {
          playNext();
        }
      }
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
    await _audioPlayer.stop();
    _position = Duration.zero;
    notifyListeners();

    final index = _songs.indexOf(song);
    if (index != -1) {
      _currentSongIndex = index;
      _currentSong = song;
    }

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
    if (_isShuffling) {
      _currentSongIndex = Random().nextInt(_songs.length);
    } else if (_currentSongIndex < _songs.length - 1) {
      _currentSongIndex++;
    } else {
      _currentSongIndex = 0;
    }
    _currentSong = _songs[_currentSongIndex];
    playSong(_currentSong!);
  }

  void playPrevious() {
    if (_isShuffling) {
      _currentSongIndex = Random().nextInt(_songs.length);
    } else if (_currentSongIndex > 0) {
      _currentSongIndex--;
    } else {
      _currentSongIndex = _songs.length - 1;
    }
    _currentSong = _songs[_currentSongIndex];
    playSong(_currentSong!);
  }

  Future<void> stopAndClear() async {
    await _audioPlayer.stop();
    _currentSong = null;
    _isPlaying = false;
    _position = Duration.zero;
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffling = !_isShuffling;
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeating = !_isRepeating;
    notifyListeners();
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