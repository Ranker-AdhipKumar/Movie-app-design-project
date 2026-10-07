import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/app_constants.dart';
import 'config/app_theme.dart';
import 'repositories/auth_repository.dart';
import 'repositories/movie_repository.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

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

  final authRepository = AuthRepository();
  final movieRepository = MovieRepository();

  runApp(MovieApp(
    repository: movieRepository,
    authRepository: authRepository,
  ));
}

/// Root widget of the application managing authentication session and routing.
class MovieApp extends StatelessWidget {
  final MovieRepository repository;
  final AuthRepository authRepository;

  const MovieApp({
    Key? key,
    required this.repository,
    required this.authRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: ListenableBuilder(
        listenable: authRepository,
        builder: (context, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: authRepository.isAuthenticated
                ? HomeScreen(
                    key: const ValueKey('HomeScreen'),
                    repository: repository,
                    authRepository: authRepository,
                  )
                : LoginScreen(
                    key: const ValueKey('LoginScreen'),
                    authRepository: authRepository,
                  ),
          );
        },
      ),
    );
  }
}
