class YoutubeVideo {
  final String id;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  final String publishedAt;
  final String description;

  YoutubeVideo({
    required this.id,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.publishedAt,
    required this.description,
  });

  factory YoutubeVideo.fromJson(Map<String, dynamic> json) {
    return YoutubeVideo(
      id: json['snippet']['resourceId']['videoId'] ?? '',
      title: json['snippet']['title'] ?? 'Untitled',
      channelTitle: json['snippet']['channelTitle'] ?? 'Unknown',
      thumbnailUrl: json['snippet']['thumbnails']['medium']['url'] ?? '',
      publishedAt: json['snippet']['publishedAt'] ?? '',
      description: json['snippet']['description'] ?? '',
    );
  }
}