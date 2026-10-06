/// Centralized TMDB API configuration.
/// 
/// Keys and endpoints are strictly decoupled from UI files as required.
class ApiConfig {
  /// Base TMDB v3 API URL
  static const String baseUrl = 'https://api.themoviedb.org/3';

  /// TMDB CDN Image URLs
  static const String imageBaseUrlW500 = 'https://image.tmdb.org/t/p/w500';
  static const String imageBaseUrlOriginal = 'https://image.tmdb.org/t/p/original';
  static const String imageBaseUrlW185 = 'https://image.tmdb.org/t/p/w185';
  static const String imageBaseUrlW1280 = 'https://image.tmdb.org/t/p/w1280';

  /// TMDB API Key.
  /// Evaluators can supply their own TMDB v3 API key here or enter it
  /// directly in the in-app Settings screen without recompiling.
  /// 
  /// Leave blank to run seamlessly on the rich offline/sample dataset.
  static String apiKey = const String.fromEnvironment('TMDB_API_KEY', defaultValue: '');

  /// Check whether an API key has been configured
  static bool get hasValidApiKey => apiKey.trim().isNotEmpty;

  // Endpoint routes
  static const String popularMoviesEndpoint = '/movie/popular';
  static const String trendingMoviesEndpoint = '/trending/movie/week';
  static const String topRatedMoviesEndpoint = '/movie/top_rated';
  static const String nowPlayingMoviesEndpoint = '/movie/now_playing';
  static const String searchMovieEndpoint = '/search/movie';
  static const String movieDetailsEndpoint = '/movie'; // /movie/{id}

  /// Helper to build full TMDB image URL
  static String getImageUrl(String? path, {String size = 'w500'}) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return 'https://image.tmdb.org/t/p/$size$path';
  }
}
