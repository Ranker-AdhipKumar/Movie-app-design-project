import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../config/app_theme.dart';
import '../models/movie.dart';
import '../repositories/movie_repository.dart';
import '../widgets/category_chip_bar.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/movie_card.dart';
import '../widgets/section_header.dart';
import '../widgets/trending_carousel_card.dart';
import 'movie_detail_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

/// Main Home Screen displaying featured trending carousel, category chips,
/// search bar, and grid of movies.
class HomeScreen extends StatefulWidget {
  final MovieRepository repository;

  const HomeScreen({
    Key? key,
    required this.repository,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _carouselController = PageController(viewportFraction: 0.92);
  final TextEditingController _searchFilterController = TextEditingController();

  List<Movie> _trendingMovies = [];
  List<Movie> _allMovies = [];
  List<Movie> _filteredMovies = [];

  String _selectedCategory = 'All';
  bool _isLoading = true;
  String? _errorMessage;
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    widget.repository.addListener(_onRepositoryChanged);
    _loadData();
    _startCarouselAutoScroll();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _carouselController.dispose();
    _searchFilterController.dispose();
    widget.repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }

  void _onRepositoryChanged() {
    _loadData();
  }

  void _startCarouselAutoScroll() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_trendingMovies.isNotEmpty && _carouselController.hasClients) {
        final nextIndex = (_currentCarouselIndex + 1) % _trendingMovies.length;
        _carouselController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final trending = await widget.repository.getTrendingMovies();
      final popular = await widget.repository.getPopularMovies(category: _selectedCategory);

      if (mounted) {
        setState(() {
          _trendingMovies = trending;
          _allMovies = popular;
          _applySearchFilter(_searchFilterController.text);
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

  void _onCategorySelected(String category) async {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _isLoading = true;
    });

    try {
      final movies = await widget.repository.getPopularMovies(category: category);
      if (mounted) {
        setState(() {
          _allMovies = movies;
          _applySearchFilter(_searchFilterController.text);
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

  void _applySearchFilter(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      _filteredMovies = List.from(_allMovies);
    } else {
      _filteredMovies = _allMovies.where((m) {
        return m.title.toLowerCase().contains(trimmed) ||
            m.overview.toLowerCase().contains(trimmed) ||
            m.genres.any((g) => g.toLowerCase().contains(trimmed));
      }).toList();
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
    ).then((_) {
      // Refresh state to update any changed favorite flags
      setState(() {
        _applySearchFilter(_searchFilterController.text);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.surfaceLight,
        onRefresh: _loadData,
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.movie_filter_rounded, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                widget.repository.isLiveMode ? 'TMDB Live API' : 'Sample Data Mode',
                style: TextStyle(
                  fontSize: 11,
                  color: widget.repository.isLiveMode ? AppTheme.successColor : AppTheme.primaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Search',
          icon: const Icon(Icons.search_rounded, color: AppTheme.textPrimary),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchScreen(repository: widget.repository),
              ),
            );
          },
        ),
        IconButton(
          tooltip: 'Settings & API Config',
          icon: const Icon(Icons.tune_rounded, color: AppTheme.textPrimary),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsScreen(repository: widget.repository),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading && _allMovies.isEmpty) {
      return _buildLoadingState();
    }

    if (_errorMessage != null && _allMovies.isEmpty) {
      return _buildErrorState(_errorMessage!);
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        // Quick inline Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: CustomSearchBar(
              controller: _searchFilterController,
              hintText: 'Search within movies & genres...',
              onChanged: (val) {
                setState(() {
                  _applySearchFilter(val);
                });
              },
              onClear: () {
                setState(() {
                  _applySearchFilter('');
                });
              },
            ),
          ),
        ),

        // Featured Trending Carousel (only when not searching)
        if (_searchFilterController.text.trim().isEmpty && _trendingMovies.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Featured & Trending',
              actionTitle: 'Swipe for more',
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: _carouselController,
                    itemCount: _trendingMovies.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentCarouselIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final movie = _trendingMovies[index];
                      return TrendingCarouselCard(
                        movie: movie,
                        onTap: () => _navigateToDetail(movie),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_trendingMovies.length, (index) {
                    final isActive = index == _currentCarouselIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 5,
                      width: isActive ? 20 : 6,
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.primary : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],

        // Category Filter Chips
        SliverToBoxAdapter(
          child: CategoryChipBar(
            selectedCategory: _selectedCategory,
            onCategorySelected: _onCategorySelected,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Section Header for Movies List
        SliverToBoxAdapter(
          child: SectionHeader(
            title: _searchFilterController.text.trim().isNotEmpty
                ? 'Search Results (${_filteredMovies.length})'
                : 'Explore Movies (${_filteredMovies.length})',
          ),
        ),

        // Movies Grid or Empty State
        if (_filteredMovies.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 14,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final movie = _filteredMovies[index];
                  return MovieCard(
                    movie: movie,
                    onTap: () => _navigateToDetail(movie),
                    onFavoriteToggle: () {
                      final added = widget.repository.toggleFavorite(movie.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppTheme.surfaceCard,
                          content: Text(
                            added
                                ? 'Added "${movie.title}" to Watchlist'
                                : 'Removed "${movie.title}" from Watchlist',
                            style: const TextStyle(color: AppTheme.textPrimary),
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: _filteredMovies.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Fetching Cinema Magic...',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Loading movie catalogs and posters',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded, color: AppTheme.errorColor, size: 48),
            ),
            const SizedBox(height: 18),
            const Text(
              'Unable to Load Movies',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try Again'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    widget.repository.setMode(DataSourceMode.sampleData);
                    _loadData();
                  },
                  child: const Text('Use Offline Mode'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_filter_outlined, color: AppTheme.textMuted, size: 64),
            const SizedBox(height: 16),
            const Text(
              'No Movies Found',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try clearing search keywords or choosing a different category.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchFilterController.clear();
                  _selectedCategory = 'All';
                  _loadData();
                });
              },
              child: const Text('Reset Filters', style: TextStyle(color: AppTheme.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
