import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport_connect/shared/widgets/app_button.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('AppButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Salvar', onPressed: () {})),
      );
      expect(find.text('Salvar'), findsOneWidget);
    });

    testWidgets('primary variant uses ElevatedButton', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(label: 'OK', onPressed: () {})),
      );
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('secondary variant uses OutlinedButton', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppButton(
            label: 'Cancelar',
            variant: AppButtonVariant.secondary,
            onPressed: () {},
          ),
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('ghost variant uses TextButton', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppButton(
            label: 'Ghost',
            variant: AppButtonVariant.ghost,
            onPressed: () {},
          ),
        ),
      );
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when isLoading', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Loading', isLoading: true, onPressed: () {})),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('onPressed callback is called on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Tap me', onPressed: () => tapped = true)),
      );
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });

    testWidgets('disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppButton(label: 'Disabled', onPressed: null)),
      );
      final button =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('renders full-width by default', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Wide', onPressed: () {})),
      );
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('renders leading icon when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppButton(
            label: 'With Icon',
            leadingIcon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
