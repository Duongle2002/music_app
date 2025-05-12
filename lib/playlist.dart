import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'song.dart';

class Playlist {
  final String name;
  final List<Song> songs;

  Playlist({required this.name, required this.songs});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }

  static Playlist fromJson(Map<String, dynamic> json) {
    return Playlist(
      name: json['name'],
      songs: (json['songs'] as List).map((songJson) => Song.fromJson(songJson)).toList(),
    );
  }
}

class PlaylistManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Playlist>> getPlaylists() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('playlists')
        .get();
    return snapshot.docs.map((doc) => Playlist.fromJson(doc.data())).toList();
  }

  Future<void> savePlaylists(List<Playlist> playlists) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final batch = _firestore.batch();
    final collectionRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('playlists');
    final snapshot = await collectionRef.get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    for (var playlist in playlists) {
      batch.set(
        collectionRef.doc(playlist.name),
        playlist.toJson(),
      );
    }
    await batch.commit();
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('playlists')
        .doc(playlist.name)
        .set(playlist.toJson());
  }

  Future<void> addPlaylist(String name) async {
    final playlists = await getPlaylists();
    if (playlists.any((p) => p.name == name)) {
      throw Exception('Danh sách phát đã tồn tại');
    }
    playlists.add(Playlist(name: name, songs: []));
    await updatePlaylist(Playlist(name: name, songs: []));
  }

  Future<void> addSongToPlaylist(String playlistName, Song song) async {
    final playlists = await getPlaylists();
    final playlistIndex = playlists.indexWhere((p) => p.name == playlistName);
    if (playlistIndex != -1) {
      playlists[playlistIndex].songs.add(song);
      await updatePlaylist(playlists[playlistIndex]);
    }
  }

  Future<void> removeSongFromPlaylist(String playlistName, Song song) async {
    final playlists = await getPlaylists();
    final playlistIndex = playlists.indexWhere((p) => p.name == playlistName);
    if (playlistIndex != -1) {
      playlists[playlistIndex].songs.removeWhere((s) => s.id == song.id);
      await updatePlaylist(playlists[playlistIndex]);
    }
  }
}