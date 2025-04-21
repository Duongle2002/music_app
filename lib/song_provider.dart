import 'package:flutter/material.dart';
import 'song.dart';
import 'api_service.dart';

class SongProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Song> _songs = [];
  bool _isLoading = false;
  String? _error;

  List<Song> get songs => _songs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSongs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _songs = await _apiService.fetchSongs();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchSongs(String query) async {
    if (query.isEmpty) {
      _songs = [];
      _error = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final songs = await _apiService.searchSongs(query);
      _songs = songs;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}