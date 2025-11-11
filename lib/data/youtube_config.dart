class YoutubeConfig {
  final String apiKey;
  final String playlistId;

  YoutubeConfig({
    required this.apiKey,
    required this.playlistId,
  });

  factory YoutubeConfig.fromJson(Map<String, dynamic> json) {
    return YoutubeConfig(
      apiKey: json['youtube_api_key'] ?? '',
      playlistId: json['youtube_playlist_id'] ?? '',
    );
  }
}