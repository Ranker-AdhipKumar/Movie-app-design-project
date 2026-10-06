import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/repositories/movie_repository.dart';

void main() {
  testWidgets('MovieApp launches and renders Home Screen successfully', (WidgetTester tester) async {
    final repository = MovieRepository();

    await tester.pumpWidget(MovieApp(repository: repository));

    // Verify app title or branding is in widget tree
    expect(find.text('FlickVault'), findsOneWidget);
  });
}
