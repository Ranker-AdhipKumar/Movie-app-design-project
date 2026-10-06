import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/movie.dart';
import '../repositories/movie_repository.dart';
import '../widgets/cast_card.dart';
import '../widgets/custom_network_image.dart';
import '../widgets/rating_badge.dart';

/// Detailed Movie Screen showing large poster, overview, metadata, cast,
/// and smooth back navigation to Home Screen.
class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final MovieRepository repository;

  const MovieDetailScreen({
    Key? key,
    required this.movie,
    required this.repository,
  }) : super(key: key);

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Movie _movie;
  bool _isLoadingDetails = false;
  bool _isOverviewExpanded = false;

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
    _fetchExtendedDetails();
  }

  Future<void> _fetchExtendedDetails() async {
    if (_movie.cast.isNotEmpty) return;

    setState(() {
      _isLoadingDetails = true;
    });

    try {
      final detailed = await widget.repository.getMovieDetails(_movie);
      if (mounted) {
        setState(() {
          _movie = detailed;
          _isLoadingDetails = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
      }
    }
  }

  void _toggleFavorite() {
    final added = widget.repository.toggleFavorite(_movie.id);
    setState(() {
      _movie = _movie.copyWith(isFavorite: added);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.surfaceCard,
        content: Text(
          added ? 'Added to Watchlist' : 'Removed from Watchlist',
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
      ),
    );
  }

  void _showTrailerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.play_circle_fill_rounded, color: AppTheme.primary, size: 56),
              const SizedBox(height: 14),
              Text(
                'Trailer: ${_movie.title}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'High definition trailer preview stream is available on TMDB & YouTube.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close Preview'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Collapsible Hero Backdrop with Back button
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.background,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.65),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  tooltip: 'Back to Movies',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.65),
                  child: IconButton(
                    icon: Icon(
                      _movie.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      color: _movie.isFavorite ? AppTheme.primary : Colors.white,
                      size: 20,
                    ),
                    tooltip: 'Save to Watchlist',
                    onPressed: _toggleFavorite,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'movie-backdrop-${_movie.id}',
                    child: CustomNetworkImage(
                      imageUrl: _movie.fullBackdropUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Dark gradient fading down to page content
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.5, 1.0],
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                          AppTheme.background,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Movie Main Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster + Title + Meta Header Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Larger Movie Poster with Hero
                      Hero(
                        tag: 'movie-poster-${_movie.id}',
                        child: Container(
                          width: 110,
                          height: 165,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.6),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CustomNetworkImage(
                              imageUrl: _movie.fullPosterUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Title & Primary Metadata
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _movie.title,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            if (_movie.tagline != null && _movie.tagline!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                '"${_movie.tagline}"',
                                style: TextStyle(
                                  color: AppTheme.primaryLight.withOpacity(0.9),
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            // Rating Score Pill
                            Row(
                              children: [
                                RatingBadge(
                                  rating: _movie.voteAverage,
                                  fontSize: 13,
                                  iconSize: 15,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${_movie.voteCount} reviews)',
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Certification & Language Pill
                            Wrap(
                              spacing: 6,
                              children: [
                                if (_movie.certification != null)
                                  _buildTag(_movie.certification!),
                                _buildTag(_movie.language),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Quick Info Stat Bar (Release Date, Duration, Language, Rating)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF222638), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.calendar_today_rounded,
                          label: 'Release Date',
                          value: _movie.releaseDate.isNotEmpty ? _movie.releaseDate : 'N/A',
                        ),
                        _buildDivider(),
                        _buildStatItem(
                          icon: Icons.access_time_rounded,
                          label: 'Duration',
                          value: _movie.formattedRuntime,
                        ),
                        _buildDivider(),
                        _buildStatItem(
                          icon: Icons.language_rounded,
                          label: 'Language',
                          value: _movie.language,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Genres
                  const Text(
                    'Genres',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _movie.genres.map((g) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF282D3F), width: 1),
                        ),
                        child: Text(
                          g,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Storyline / Full Overview
                  const Text(
                    'Storyline & Overview',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: _isOverviewExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: Text(
                      _movie.overview,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    secondChild: Text(
                      _movie.overview,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  if (_movie.overview.length > 140)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isOverviewExpanded = !_isOverviewExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          _isOverviewExpanded ? 'Show less' : 'Read more',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Key Cast section
                  if (_movie.cast.isNotEmpty) ...[
                    const Text(
                      'Cast & Characters',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 125,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _movie.cast.length,
                        itemBuilder: (context, index) {
                          return CastCard(cast: _movie.cast[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Action Buttons (Watch Trailer & Watchlist)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showTrailerDialog,
                          icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 22),
                          label: const Text('Watch Trailer'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _toggleFavorite,
                        icon: Icon(
                          _movie.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                          color: _movie.isFavorite ? AppTheme.primary : AppTheme.textPrimary,
                          size: 20,
                        ),
                        label: Text(
                          _movie.isFavorite ? 'Saved' : 'Watchlist',
                          style: TextStyle(
                            color: _movie.isFavorite ? AppTheme.primary : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF282D3F), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 26,
      width: 1,
      color: const Color(0xFF232738),
    );
  }
}
