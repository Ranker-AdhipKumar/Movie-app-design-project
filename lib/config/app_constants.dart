/// Application wide constants for FlickVault / Movie App.
class AppConstants {
  static const String appName = 'FlickVault';
  static const String appTagline = 'Discover, Explore & Track Cinema';
  
  // Storage keys
  static const String sampleMoviesAssetPath = 'assets/data/sample_movies.json';

  // Default fallback image if network fails
  static const String fallbackPosterUrl =
      'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=500&auto=format&fit=crop&q=60';
  static const String fallbackBackdropUrl =
      'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=1280&auto=format&fit=crop&q=80';

  // Movie genres for quick filtering
  static const List<String> categories = [
    'All',
    'Action',
    'Sci-Fi',
    'Drama',
    'Animation',
    'Comedy',
    'Thriller',
    'Adventure',
    'Fantasy',
    'Crime',
  ];
}
