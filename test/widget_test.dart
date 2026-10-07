import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/repositories/auth_repository.dart';
import 'package:movie_app/repositories/movie_repository.dart';
import 'package:movie_app/widgets/rating_badge.dart';
import 'package:movie_app/widgets/category_chip_bar.dart';

void main() {
  testWidgets('RatingBadge renders rating score correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RatingBadge(rating: 8.4),
        ),
      ),
    );

    expect(find.text('8.4'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
  });

  testWidgets('CategoryChipBar displays categories', (WidgetTester tester) async {
    String selected = 'All';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryChipBar(
            selectedCategory: selected,
            onCategorySelected: (cat) => selected = cat,
          ),
        ),
      ),
    );

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);
  });

  testWidgets('MovieApp launches with LoginScreen when unauthenticated', (WidgetTester tester) async {
    final movieRepository = MovieRepository();
    final authRepository = AuthRepository();

    await tester.pumpWidget(MovieApp(
      repository: movieRepository,
      authRepository: authRepository,
    ));

    // Initially unauthenticated: shows login branding and buttons
    expect(find.text('FlickVault'), findsOneWidget);
    expect(find.text('Sign In to FlickVault'), findsOneWidget);
    expect(find.text('Fill Demo Account (1-Click)'), findsOneWidget);

    // Unmount cleanly
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
