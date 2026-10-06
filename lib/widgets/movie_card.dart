import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/movie.dart';
import 'custom_network_image.dart';
import 'rating_badge.dart';

/// Clean movie card displaying poster, title, rating, release year, and genres.
class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;

  const MovieCard({
    Key? key,
    required this.movie,
    required this.onTap,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF222638), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster with floating favorite button & rating
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'movie-poster-${movie.id}',
                      child: CustomNetworkImage(
                        imageUrl: movie.fullPosterUrl,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Subtle bottom gradient over poster for contrast
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Top Left Rating Badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: RatingBadge(rating: movie.voteAverage),
                    ),

                    // Top Right Bookmark / Favorite Button
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Material(
                        color: Colors.black.withOpacity(0.6),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onFavoriteToggle,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              movie.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                              color: movie.isFavorite ? AppTheme.primary : Colors.white70,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Movie Meta info
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          movie.releaseYear,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          '•',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            movie.genres.isNotEmpty ? movie.genres.first : 'Cinema',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
