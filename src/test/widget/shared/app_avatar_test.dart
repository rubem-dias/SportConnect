import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport_connect/shared/widgets/app_avatar.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('AppAvatar', () {
    testWidgets('shows initials when no imageUrl', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppAvatar(name: 'João Silva')),
      );
      expect(find.text('JS'), findsOneWidget);
    });

    testWidgets('shows single initial for single-word name', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppAvatar(name: 'Admin')),
      );
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('shows ? for null name', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppAvatar()),
      );
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('onTap callback is called', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(AppAvatar(name: 'Test', onTap: () => tapped = true)),
      );
      await tester.tap(find.byType(AppAvatar));
      expect(tapped, isTrue);
    });

    testWidgets('does not show Positioned indicator by default', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppAvatar(name: 'Test')),
      );
      // No Positioned indicator widget when showOnlineIndicator is false
      expect(find.byType(Positioned), findsNothing);
    });

    testWidgets('shows Positioned indicator when enabled', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppAvatar(
            name: 'Test',
            showOnlineIndicator: true,
            isOnline: true,
          ),
        ),
      );
      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('renders xs size correctly', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppAvatar(name: 'XS', size: AppAvatarSize.xs)),
      );
      expect(find.byType(AppAvatar), findsOneWidget);
    });
  });
}
