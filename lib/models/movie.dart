import '../config/api_config.dart';
import '../config/app_constants.dart';
import 'cast_member.dart';

/// Complete domain model for a movie.
class Movie {
  final int id;
  final String title;
  final String? tagline;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final int? runtime;
  final List<String> genres;
  final String language;
  final String? certification;
  final List<CastMember> cast;
  final bool isFavorite;

  const Movie({
    required this.id,
    required this.title,
    this.tagline,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    this.voteCount = 0,
    required this.releaseDate,
    this.runtime,
    this.genres = const [],
    this.language = 'English',
    this.certification,
    this.cast = const [],
    this.isFavorite = false,
  });

  /// Factory parser that supports both TMDB live API response and local sample JSON
  factory Movie.fromJson(Map<String, dynamic> json) {
    // Genres parsing from TMDB or local array
    List<String> parsedGenres = [];
    if (json['genres'] != null) {
      if (json['genres'] is List) {
        for (final item in json['genres']) {
          if (item is String) {
            parsedGenres.add(item);
          } else if (item is Map && item['name'] != null) {
            parsedGenres.add(item['name'].toString());
          }
        }
      }
    } else if (json['genre_ids'] != null && json['genre_ids'] is List) {
      // Map common TMDB genre IDs to readable names
      parsedGenres = _mapGenreIds((json['genre_ids'] as List).cast<int>());
    }

    // Cast parsing
    List<CastMember> parsedCast = [];
    if (json['cast'] != null && json['cast'] is List) {
      parsedCast = (json['cast'] as List)
          .map((c) => CastMember.fromJson(c as Map<String, dynamic>))
          .toList();
    }

    return Movie(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled',
      tagline: json['tagline'] as String?,
      overview: (json['overview'] as String?)?.isNotEmpty == true
          ? json['overview'] as String
          : 'No overview available.',
      posterPath: json['posterPath'] as String? ?? json['poster_path'] as String?,
      backdropPath: json['backdropPath'] as String? ?? json['backdrop_path'] as String?,
      voteAverage: (json['voteAverage'] as num?)?.toDouble() ??
          (json['vote_average'] as num?)?.toDouble() ??
          0.0,
      voteCount: json['voteCount'] as int? ?? json['vote_count'] as int? ?? 0,
      releaseDate: json['releaseDate'] as String? ?? json['release_date'] as String? ?? '',
      runtime: json['runtime'] as int?,
      genres: parsedGenres.isNotEmpty ? parsedGenres : ['Drama'],
      language: json['language'] as String? ??
          (json['original_language'] != null
              ? _mapLanguageCode(json['original_language'].toString())
              : 'English'),
      certification: json['certification'] as String? ?? 'PG-13',
      cast: parsedCast,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tagline': tagline,
      'overview': overview,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'voteAverage': voteAverage,
      'voteCount': voteCount,
      'releaseDate': releaseDate,
      'runtime': runtime,
      'genres': genres,
      'language': language,
      'certification': certification,
      'cast': cast.map((c) => c.toJson()).toList(),
      'isFavorite': isFavorite,
    };
  }

  Movie copyWith({
    int? id,
    String? title,
    String? tagline,
    String? overview,
    String? posterPath,
    String? backdropPath,
    double? voteAverage,
    int? voteCount,
    String? releaseDate,
    int? runtime,
    List<String>? genres,
    String? language,
    String? certification,
    List<CastMember>? cast,
    bool? isFavorite,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      tagline: tagline ?? this.tagline,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      releaseDate: releaseDate ?? this.releaseDate,
      runtime: runtime ?? this.runtime,
      genres: genres ?? this.genres,
      language: language ?? this.language,
      certification: certification ?? this.certification,
      cast: cast ?? this.cast,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Getters for display presentation
  String get releaseYear {
    if (releaseDate.isEmpty) return 'N/A';
    try {
      final parts = releaseDate.split('-');
      if (parts.isNotEmpty && parts[0].length == 4) {
        return parts[0];
      }
    } catch (_) {}
    return 'N/A';
  }

  String get formattedRuntime {
    if (runtime == null || runtime! <= 0) return '2h 10m';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  double get ratingOutOf5 => (voteAverage / 2.0).clamp(0.0, 5.0);

  String get ratingFormatted => voteAverage.toStringAsFixed(1);

  String get fullPosterUrl {
    if (posterPath == null || posterPath!.isEmpty) {
      return AppConstants.fallbackPosterUrl;
    }
    return ApiConfig.getImageUrl(posterPath, size: 'w500');
  }

  String get fullBackdropUrl {
    if (backdropPath == null || backdropPath!.isEmpty) {
      return fullPosterUrl;
    }
    return ApiConfig.getImageUrl(backdropPath, size: 'w1280');
  }

  String get genresString => genres.join(' • ');

  static List<String> _mapGenreIds(List<int> ids) {
    const genreMap = {
      28: 'Action',
      12: 'Adventure',
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      14: 'Fantasy',
      36: 'History',
      27: 'Horror',
      10402: 'Music',
      9648: 'Mystery',
      10749: 'Romance',
      878: 'Sci-Fi',
      10770: 'TV Movie',
      53: 'Thriller',
      10752: 'War',
      37: 'Western',
    };
    return ids.map((id) => genreMap[id] ?? 'Cinema').toList();
  }

  static String _mapLanguageCode(String code) {
    const langMap = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'ja': 'Japanese',
      'ko': 'Korean',
      'de': 'German',
      'hi': 'Hindi',
      'it': 'Italian',
      'zh': 'Chinese',
    };
    return langMap[code.toLowerCase()] ?? code.toUpperCase();
  }
}
