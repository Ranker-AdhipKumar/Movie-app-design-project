import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/models/cast_member.dart';

void main() {
  group('Movie Model Tests', () {
    test('Movie properly deserializes from TMDB JSON structure', () {
      final json = {
        'id': 27205,
        'title': 'Inception',
        'tagline': 'Your mind is the scene of the crime.',
        'overview': 'Cobb is a skilled thief...',
        'poster_path': '/ljsZTbVsrQSqZgWeep2B1QiDKuh.jpg',
        'backdrop_path': '/8ZTVqvKDQ8emSGUEMjsS4yHAwrp.jpg',
        'vote_average': 8.364,
        'vote_count': 35420,
        'release_date': '2010-07-16',
        'runtime': 148,
        'original_language': 'en',
      };

      final movie = Movie.fromJson(json);

      expect(movie.id, 27205);
      expect(movie.title, 'Inception');
      expect(movie.releaseYear, '2010');
      expect(movie.formattedRuntime, '2h 28m');
      expect(movie.ratingFormatted, '8.4');
      expect(movie.language, 'English');
      expect(movie.fullPosterUrl, contains('image.tmdb.org'));
    });

    test('Movie properly handles null and missing fields with graceful defaults', () {
      final json = {
        'id': 999,
        'title': 'Mystery Movie',
      };

      final movie = Movie.fromJson(json);

      expect(movie.id, 999);
      expect(movie.title, 'Mystery Movie');
      expect(movie.releaseYear, 'N/A');
      expect(movie.voteAverage, 0.0);
      expect(movie.fullPosterUrl.isNotEmpty, true);
    });

    test('CastMember model serializes and deserializes cleanly', () {
      final json = {
        'name': 'Leonardo DiCaprio',
        'character': 'Dom Cobb',
        'profilePath': '/wo2hJpn04vbtmh0B9utCFdsQhxM.jpg',
      };

      final cast = CastMember.fromJson(json);

      expect(cast.name, 'Leonardo DiCaprio');
      expect(cast.character, 'Dom Cobb');
      expect(cast.profilePath, '/wo2hJpn04vbtmh0B9utCFdsQhxM.jpg');
    });

    test('copyWith toggles favorite and preserves existing fields', () {
      const movie = Movie(
        id: 1,
        title: 'Interstellar',
        overview: 'Space journey',
        voteAverage: 8.7,
        releaseDate: '2014-11-07',
        isFavorite: false,
      );

      final updated = movie.copyWith(isFavorite: true);

      expect(updated.isFavorite, true);
      expect(updated.id, movie.id);
      expect(updated.title, movie.title);
    });
  });
}
