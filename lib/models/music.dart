class Music {
  final String id;
  final String title;
  final String artist;
  final String duration;
  final String assetPath; // Path to audio file
  final String coverArt; // Path to cover image

  Music({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.assetPath,
    required this.coverArt,
  });
}
