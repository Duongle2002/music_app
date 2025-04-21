class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final int duration;
  final String url;
  final String coverUrl;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.url,
    required this.coverUrl,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      duration: json['duration'],
      url: json['url'],
      coverUrl: json['cover_url'],
    );
  }
}