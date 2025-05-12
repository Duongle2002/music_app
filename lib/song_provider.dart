import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'song.dart';
import 'api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

    final prefs = await SharedPreferences.getInstance();
    final cachedSongs = prefs.getString('cached_songs');
    if (cachedSongs != null) {
      _songs = (jsonDecode(cachedSongs) as List).map((e) => Song.fromJson(e)).toList();
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _songs = await _apiService.fetchSongs();
      await prefs.setString('cached_songs', jsonEncode(_songs.map((e) => e.toJson()).toList()));
    } catch (e) {
      _error = e is http.ClientException ? 'Lỗi kết nối mạng' : 'Lỗi tải bài hát: $e';
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
      _error = e is http.ClientException ? 'Lỗi kết nối mạng' : 'Lỗi tìm kiếm bài hát: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}