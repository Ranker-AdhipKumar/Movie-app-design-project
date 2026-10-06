import 'dart:convert';
import 'package:flutter/services.dart';
import '../config/app_constants.dart';
import '../models/movie.dart';

/// Provides reliable offline and sample movie data for the app.
/// 
/// Fulfills requirement:
/// "Store 5–10 sample movies using: (Hardcoded lists, JSON files, Arrays or models)."
class MockMovieService {
  /// Load sample movies from local JSON asset with in-memory fallback.
  static Future<List<Movie>> loadSampleMovies() async {
    try {
      final jsonString = await rootBundle.loadString(AppConstants.sampleMoviesAssetPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((item) => Movie.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      // In-memory fallback if asset bundle is unavailable (e.g. running unit tests)
      return _getHardcodedFallbackMovies();
    }
  }

  /// Backup hardcoded list ensuring the app works even in headless unit tests.
  static List<Movie> _getHardcodedFallbackMovies() {
    return [
      const Movie(
        id: 27205,
        title: 'Inception',
        tagline: 'Your mind is the scene of the crime.',
        overview:
            'Cobb, a skilled thief who steals corporate secrets through use of dream-sharing technology, is offered a chance to have his criminal history erased as payment for the implantation of another person\'s idea into a target\'s subconscious.',
        posterPath: 'https://image.tmdb.org/t/p/w500/ljsZTbVsrQSqZgWeep2B1QiDKuh.jpg',
        backdropPath: 'https://image.tmdb.org/t/p/w1280/8ZTVqvKDQ8emSGUEMjsS4yHAwrp.jpg',
        voteAverage: 8.4,
        voteCount: 35420,
        releaseDate: '2010-07-16',
        runtime: 148,
        genres: ['Action', 'Sci-Fi', 'Adventure'],
        language: 'English',
        certification: 'PG-13',
      ),
      const Movie(
        id: 157336,
        title: 'Interstellar',
        tagline: 'Mankind was born on Earth. It was never meant to die here.',
        overview:
            'The adventures of a group of explorers who make use of a newly discovered wormhole to surpass the limitations on human space travel and conquer the vast distances involved in an interstellar voyage.',
        posterPath: 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
        backdropPath: 'https://image.tmdb.org/t/p/w1280/xJHokMbljvjADYdit5fK5VQsXEG.jpg',
        voteAverage: 8.7,
        voteCount: 34100,
        releaseDate: '2014-11-07',
        runtime: 169,
        genres: ['Sci-Fi', 'Drama', 'Adventure'],
        language: 'English',
        certification: 'PG-13',
      ),
      const Movie(
        id: 155,
        title: 'The Dark Knight',
        tagline: 'Why so serious?',
        overview:
            'Batman raises the stakes in his war on crime. With the help of allies Lt. Jim Gordon and DA Harvey Dent, Batman sets out to dismantle the remaining criminal organizations that plague the streets.',
        posterPath: 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
        backdropPath: 'https://image.tmdb.org/t/p/w1280/dqK9Hag1054tghRQSqLSPoYqA5P.jpg',
        voteAverage: 9.0,
        voteCount: 31500,
        releaseDate: '2008-07-18',
        runtime: 152,
        genres: ['Action', 'Crime', 'Drama'],
        language: 'English',
        certification: 'PG-13',
      ),
      const Movie(
        id: 693134,
        title: 'Dune: Part Two',
        tagline: 'Long live the fighters.',
        overview:
            'Follow the mythic journey of Paul Atreides as he unites with Chani and the Fremen while on a warpath of revenge against the conspirators who destroyed his family.',
        posterPath: 'https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg',
        backdropPath: 'https://image.tmdb.org/t/p/w1280/xOMo8BRK7PfcJv9JCnx7s5hj0x2.jpg',
        voteAverage: 8.3,
        voteCount: 5120,
        releaseDate: '2024-03-01',
        runtime: 166,
        genres: ['Sci-Fi', 'Adventure', 'Action'],
        language: 'English',
        certification: 'PG-13',
      ),
      const Movie(
        id: 569094,
        title: 'Spider-Man: Across the Spider-Verse',
        tagline: 'It\'s how you wear the mask that matters.',
        overview:
            'After reuniting with Gwen Stacy, Brooklyn’s full-time, friendly neighborhood Spider-Man is catapulted across the Multiverse, where he encounters the Spider Society.',
        posterPath: 'https://image.tmdb.org/t/p/w500/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg',
        backdropPath: 'https://image.tmdb.org/t/p/w1280/4HodYYKEIsGOdinkGi2Ucz6X9i0.jpg',
        voteAverage: 8.4,
        voteCount: 6700,
        releaseDate: '2023-06-02',
        runtime: 140,
        genres: ['Animation', 'Action', 'Adventure'],
        language: 'English',
        certification: 'PG',
      ),
    ];
  }
}
