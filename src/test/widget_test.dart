import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sport_connect/app.dart';
import 'package:sport_connect/core/env/env.dart';

void main() {
  testWidgets('App bootstraps with ProviderScope', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SportConnectApp(flavor: AppFlavor.dev),
      ),
    );
    await tester.pump();

    expect(find.byType(SportConnectApp), findsOneWidget);
  });
}
