import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:life_hub/app/life_hub_app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('shows Firebase setup guidance when options are missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const LifeHubApp(
        firebaseState: FirebaseStartupState.notConfigured(
          'Run flutterfire configure.',
        ),
      ),
    );

    expect(find.text('Life Hub'), findsOneWidget);
    expect(find.text('Firebase setup needed'), findsOneWidget);
    expect(find.text('flutterfire configure'), findsOneWidget);
  });
}
