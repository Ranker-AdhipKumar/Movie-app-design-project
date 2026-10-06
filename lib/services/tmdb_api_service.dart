import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/movie.dart';

/// Exception thrown when TMDB API call fails.
class TmdbApiException implements Exception {
  final String message;
  final int? statusCode;

  const TmdbApiException(this.message, {this.statusCode});

  @override
  String toString() => 'TmdbApiException: $message (Status: $statusCode)';
}

/// Service handling all HTTP communication with The Movie Database (TMDB).
/// 
/// Fulfills requirement:
/// "Refer this website for the api: https://developer.themoviedb.org/docs/getting-started
/// Implement:
/// - API key handling (do not hardcode in UI files)
/// - Loading indicators
/// - Error handling for failed requests
/// - Search movies using TMDB's search endpoint"
class TmdbApiService {
  final http.Client _client;
  final Duration _timeoutDuration;

  TmdbApiService({
    http.Client? client,
    Duration timeoutDuration = const Duration(seconds: 12),
  })  : _client = client ?? http.Client(),
        _timeoutDuration = timeoutDuration;

  /// Helper to build URI with authentication query param
  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final params = <String, String>{
      'api_key': ApiConfig.apiKey,
      'language': 'en-US',
      ...?queryParams,
    };
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: params);
  }

  /// Generic GET request with timeout and error mapping
  Future<dynamic> _get(String path, [Map<String, String>? queryParams]) async {
    if (!ApiConfig.hasValidApiKey) {
      throw const TmdbApiException(
        'TMDB API Key is missing. Please configure your key in Settings or run with sample data.',
        statusCode: 401,
      );
    }

    final url = _buildUri(path, queryParams);

    try {
      final response = await _client.get(url).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw const TmdbApiException(
          'Invalid TMDB API Key. Please verify your credentials.',
          statusCode: 401,
        );
      } else if (response.statusCode == 404) {
        throw const TmdbApiException('The requested resource was not found.', statusCode: 404);
      } else {
        throw TmdbApiException(
          'Failed to load data from TMDB (HTTP ${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const TmdbApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw const TmdbApiException('Connection timed out. Please try again later.');
    } on FormatException {
      throw const TmdbApiException('Invalid data format received from server.');
    } catch (e) {
      if (e is TmdbApiException) rethrow;
      throw TmdbApiException('Unexpected error: $e');
    }
  }

  /// Fetch popular movies
  Future<List<Movie>> fetchPopularMovies({int page = 1}) async {
    final data = await _get(
      ApiConfig.popularMoviesEndpoint,
      {'page': page.toString()},
    );

    final results = data['results'] as List<dynamic>? ?? [];
    return results.map((item) => Movie.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Fetch trending movies of the week
  Future<List<Movie>> fetchTrendingMovies() async {
    final data = await _get(ApiConfig.trendingMoviesEndpoint);
    final results = data['results'] as List<dynamic>? ?? [];
    return results.map((item) => Movie.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Search movies by title query using TMDB `/search/movie` endpoint
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];

    final data = await _get(
      ApiConfig.searchMovieEndpoint,
      {
        'query': query.trim(),
        'page': page.toString(),
        'include_adult': 'false',
      },
    );

    final results = data['results'] as List<dynamic>? ?? [];
    return results.map((item) => Movie.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Fetch detailed movie info including credits / cast
  Future<Movie> fetchMovieDetails(int movieId) async {
    final data = await _get(
      '${ApiConfig.movieDetailsEndpoint}/$movieId',
      {'append_to_response': 'credits'},
    );

    // Extract cast from appended credits if available
    final credits = data['credits'] as Map<String, dynamic>?;
    final castList = credits != null ? credits['cast'] as List<dynamic>? : null;

    final movie = Movie.fromJson(data as Map<String, dynamic>);

    if (castList != null && castList.isNotEmpty) {
      final parsedCast = castList
          .take(8)
          .map((c) => CastMember.fromJson(c as Map<String, dynamic>))
          .toList();
      return movie.copyWith(cast: parsedCast);
    }

    return movie;
  }
}
