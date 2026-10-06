import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/movie.dart';
import '../services/mock_movie_service.dart';
import '../services/tmdb_api_service.dart';

enum DataSourceMode {
  sampleData,
  tmdbLive,
}

/// Unified repository managing movie data fetching, local caching,
/// search filtering, category filtering, and favorites state.
class MovieRepository extends ChangeNotifier {
  final TmdbApiService _apiService;
  
  DataSourceMode _currentMode = ApiConfig.hasValidApiKey
      ? DataSourceMode.tmdbLive
      : DataSourceMode.sampleData;

  List<Movie> _cachedSampleMovies = [];
  final Set<int> _favoriteMovieIds = {};
  String? _lastErrorMessage;

  MovieRepository({TmdbApiService? apiService})
      : _apiService = apiService ?? TmdbApiService();

  DataSourceMode get currentMode => _currentMode;
  bool get isLiveMode => _currentMode == DataSourceMode.tmdbLive;
  String? get lastErrorMessage => _lastErrorMessage;
  Set<int> get favoriteMovieIds => _favoriteMovieIds;

  void setMode(DataSourceMode mode) {
    if (_currentMode != mode) {
      _currentMode = mode;
      notifyListeners();
    }
  }

  void updateApiKey(String key) {
    ApiConfig.apiKey = key.trim();
    if (ApiConfig.hasValidApiKey) {
      _currentMode = DataSourceMode.tmdbLive;
    } else {
      _currentMode = DataSourceMode.sampleData;
    }
    notifyListeners();
  }

  /// Ensure sample movies are loaded in memory
  Future<List<Movie>> _getSampleMovies() async {
    if (_cachedSampleMovies.isEmpty) {
      _cachedSampleMovies = await MockMovieService.loadSampleMovies();
    }
    return _applyFavoriteFlags(_cachedSampleMovies);
  }

  /// Fetch trending movies (for carousel)
  Future<List<Movie>> getTrendingMovies() async {
    _lastErrorMessage = null;
    if (_currentMode == DataSourceMode.tmdbLive && ApiConfig.hasValidApiKey) {
      try {
        final movies = await _apiService.fetchTrendingMovies();
        return _applyFavoriteFlags(movies);
      } catch (e) {
        _lastErrorMessage = 'Live trending failed: $e. Using offline sample data.';
        // Fallback to sample
        final fallback = await _getSampleMovies();
        return fallback.take(5).toList();
      }
    }
    final sample = await _getSampleMovies();
    return sample.take(5).toList();
  }

  /// Fetch popular movies list
  Future<List<Movie>> getPopularMovies({String category = 'All'}) async {
    _lastErrorMessage = null;
    List<Movie> movies = [];

    if (_currentMode == DataSourceMode.tmdbLive && ApiConfig.hasValidApiKey) {
      try {
        movies = await _apiService.fetchPopularMovies();
      } catch (e) {
        _lastErrorMessage = 'Live API error: $e. Showing offline sample data.';
        movies = await _getSampleMovies();
      }
    } else {
      movies = await _getSampleMovies();
    }

    // Filter by category if specified and not 'All'
    if (category != 'All') {
      movies = movies.where((m) {
        return m.genres.any((g) => g.toLowerCase().contains(category.toLowerCase()));
      }).toList();
    }

    return _applyFavoriteFlags(movies);
  }

  /// Search movies by title query (supports both TMDB live search and sample local filtering)
  Future<List<Movie>> searchMovies(String query) async {
    _lastErrorMessage = null;
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return [];

    if (_currentMode == DataSourceMode.tmdbLive && ApiConfig.hasValidApiKey) {
      try {
        final results = await _apiService.searchMovies(trimmed);
        return _applyFavoriteFlags(results);
      } catch (e) {
        _lastErrorMessage = 'Live search error: $e. Searching offline data.';
        // Fallback to sample data search
      }
    }

    // Offline search
    final samples = await _getSampleMovies();
    final filtered = samples.where((m) {
      final matchesTitle = m.title.toLowerCase().contains(trimmed);
      final matchesOverview = m.overview.toLowerCase().contains(trimmed);
      final matchesGenre = m.genres.any((g) => g.toLowerCase().contains(trimmed));
      return matchesTitle || matchesOverview || matchesGenre;
    }).toList();

    return _applyFavoriteFlags(filtered);
  }

  /// Fetch full details for a movie
  Future<Movie> getMovieDetails(Movie initialMovie) async {
    if (_currentMode == DataSourceMode.tmdbLive && ApiConfig.hasValidApiKey) {
      try {
        final detailed = await _apiService.fetchMovieDetails(initialMovie.id);
        return detailed.copyWith(
          isFavorite: _favoriteMovieIds.contains(detailed.id),
        );
      } catch (_) {
        // Fallback to existing movie model
      }
    }

    // If already has cast or from sample data
    return initialMovie.copyWith(
      isFavorite: _favoriteMovieIds.contains(initialMovie.id),
    );
  }

  /// Toggle movie favorite / watchlist state
  bool toggleFavorite(int movieId) {
    final isFav = _favoriteMovieIds.contains(movieId);
    if (isFav) {
      _favoriteMovieIds.remove(movieId);
    } else {
      _favoriteMovieIds.add(movieId);
    }
    notifyListeners();
    return !isFav;
  }

  bool isFavorite(int movieId) => _favoriteMovieIds.contains(movieId);

  List<Movie> _applyFavoriteFlags(List<Movie> movies) {
    return movies.map((m) {
      return m.copyWith(isFavorite: _favoriteMovieIds.contains(m.id));
    }).toList();
  }
}
