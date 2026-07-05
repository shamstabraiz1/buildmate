import 'package:buildmate/app/build_mate_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts on splash route', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BuildMateApp()));

    expect(find.text('BuildMate'), findsOneWidget);
    expect(
      find.text('Plan, track, and deliver construction work.'),
      findsOneWidget,
    );
  });
}
