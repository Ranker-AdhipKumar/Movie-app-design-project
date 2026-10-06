import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/movie.dart';
import '../repositories/movie_repository.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_screen.dart';

/// Dedicated Search Screen supporting live TMDB endpoint search & sample fallback.
class SearchScreen extends StatefulWidget {
  final MovieRepository repository;

  const SearchScreen({
    Key? key,
    required this.repository,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  List<Movie> _results = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSearched = false;

  final List<String> _suggestions = [
    'Oppenheimer',
    'Interstellar',
    'Batman',
    'Spider-Man',
    'Inception',
    'Dune',
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
        _hasSearched = false;
        _errorMessage = null;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _executeSearch(query);
    });
  }

  Future<void> _executeSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = null;
    });

    try {
      final results = await widget.repository.searchMovies(trimmed);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _navigateToDetail(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(
          movie: movie,
          repository: widget.repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CustomSearchBar(
            controller: _searchController,
            autofocus: true,
            hintText: 'Search TMDB movie titles...',
            onChanged: _onSearchChanged,
            onClear: () {
              setState(() {
                _results = [];
                _hasSearched = false;
                _errorMessage = null;
              });
            },
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Searching TMDB movies database...',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppTheme.errorColor, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Search Request Failed',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _executeSearch(_searchController.text),
                child: const Text('Retry Search'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasSearched) {
      return _buildSuggestionsState();
    }

    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded, color: AppTheme.textMuted, size: 56),
              const SizedBox(height: 14),
              Text(
                'No results for "${_searchController.text}"',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Check for spelling mistakes or try searching with different keywords.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Found ${_results.length} movie${_results.length > 1 ? 's' : ''}',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 14,
                mainAxisSpacing: 16,
              ),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final movie = _results[index];
                return MovieCard(
                  movie: movie,
                  onTap: () => _navigateToDetail(movie),
                  onFavoriteToggle: () {
                    widget.repository.toggleFavorite(movie.id);
                    setState(() {});
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsState() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Searches',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((s) {
              return ActionChip(
                backgroundColor: AppTheme.surfaceLight,
                label: Text(s),
                labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                side: const BorderSide(color: Color(0xFF282D3F)),
                onPressed: () {
                  _searchController.text = s;
                  _executeSearch(s);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
