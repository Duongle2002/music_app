import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/firebase_options.dart';
import 'package:music_app/login_screen.dart';
import 'package:music_app/signup_screen.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'song.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'player_screen.dart';
import 'song_provider.dart';
import 'offline_manager.dart';
import 'auth_provider.dart';
import 'profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SongProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider()),
        ChangeNotifierProvider(create: (_) => AuthProviders()),
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
        home: AuthWrapper(),
        routes: {
          '/home': (context) => HomeScreen(),
          '/search': (context) => SearchScreen(),
          '/library': (context) => LibraryScreen(),
          '/player': (context) => PlayerScreen(),
          '/profile': (context) => ProfileScreen(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignUpScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Lỗi xác thực. Vui lòng thử lại.')),
          );
        }
        if (snapshot.hasData) {
          return HomeScreen();
        }
        return LoginScreen();
      },
    );
  }
}

// Keep AudioPlayerProvider unchanged
class AudioPlayerProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Song> _songs = [];
  int _currentSongIndex = 0;
  Song? _currentSong;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  bool _isShuffling = false;
  bool _isRepeating = false;
  Song? _nextSong;
  final OfflineManager _offlineManager = OfflineManager();
  bool _isUserPaused = false;

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
      if (state == ProcessingState.completed && !_isUserPaused) {
        if (_isRepeating) {
          playSong(_currentSong!);
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
      _preloadNextSong();
    }
    notifyListeners();
  }

  Future<void> playSong(Song song) async {
    await _audioPlayer.stop();
    _position = Duration.zero;
    _isUserPaused = false;
    notifyListeners();

    final index = _songs.indexOf(song);
    if (index != -1) {
      _currentSongIndex = index;
      _currentSong = song;
    }

    try {
      final localPath = await _offlineManager.getLocalSongPath(song);
      if (localPath != null) {
        await _audioPlayer.setFilePath(localPath);
      } else {
        await _audioPlayer.setUrl(song.url);
      }
      await _audioPlayer.play();
      _isPlaying = true;
      _preloadNextSong();
    } catch (e) {
      _isPlaying = false;
      print('Error playing song: $e');
    }
    notifyListeners();
  }

  Future<void> _preloadNextSong() async {
    _nextSong = null;
    int nextIndex;
    if (_isShuffling) {
      nextIndex = Random().nextInt(_songs.length);
    } else if (_currentSongIndex < _songs.length - 1) {
      nextIndex = _currentSongIndex + 1;
    } else {
      nextIndex = 0;
    }
    _nextSong = _songs[nextIndex];
    if (_nextSong != null) {
      try {
        final localPath = await _offlineManager.getLocalSongPath(_nextSong!);
        if (localPath != null) {
          await _audioPlayer.setFilePath(localPath, preload: true);
        } else {
          await _audioPlayer.setUrl(_nextSong!.url, preload: true);
        }
      } catch (e) {
        print('Error preloading next song: $e');
      }
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isUserPaused = true;
    } else {
      await _audioPlayer.play();
      _isUserPaused = false;
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
    _nextSong = null;
    _isPlaying = false;
    _position = Duration.zero;
    _isUserPaused = false;
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffling = !_isShuffling;
    if (_isShuffling) {
      _isRepeating = false;
    }
    _preloadNextSong();
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeating = !_isRepeating;
    if (_isRepeating) {
      _isShuffling = false;
    }
    notifyListeners();
  }

  Future<void> downloadSong(Song song) async {
    await _offlineManager.downloadSong(song);
    notifyListeners();
  }

  Future<bool> isSongDownloaded(Song song) async {
    return await _offlineManager.isSongDownloaded(song);
  }

  Future<void> deleteSong(Song song) async {
    await _offlineManager.deleteSong(song);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}