import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/app_constants.dart';
import 'config/app_theme.dart';
import 'repositories/movie_repository.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive dark status bar and navigation bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final movieRepository = MovieRepository();

  runApp(MovieApp(repository: movieRepository));
}

/// Root widget of the application.
class MovieApp extends StatelessWidget {
  final MovieRepository repository;

  const MovieApp({
    Key? key,
    required this.repository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomeScreen(repository: repository),
    );
  }
}
