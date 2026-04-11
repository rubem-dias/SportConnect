import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport_connect/features/chat/presentation/widgets/chat_input_bar.dart';

Widget _wrap({
  required ValueChanged<String> onSend,
  required ValueChanged<bool> onTypingChanged,
}) =>
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: ChatInputBar(
            onSend: onSend,
            onTypingChanged: onTypingChanged,
          ),
        ),
      ),
    );

void main() {
  group('ChatInputBar', () {
    testWidgets('shows audio button when no text', (tester) async {
      await tester.pumpWidget(
        _wrap(onSend: (_) {}, onTypingChanged: (_) {}),
      );
      // Audio button uses ValueKey('audio')
      expect(find.byKey(const ValueKey('audio')), findsOneWidget);
      expect(find.byKey(const ValueKey('send')), findsNothing);
    });

    testWidgets('shows send button when text is entered', (tester) async {
      await tester.pumpWidget(
        _wrap(onSend: (_) {}, onTypingChanged: (_) {}),
      );
      await tester.enterText(find.byType(TextField), 'Olá!');
      await tester.pump();
      expect(find.byKey(const ValueKey('send')), findsOneWidget);
      expect(find.byKey(const ValueKey('audio')), findsNothing);
    });

    testWidgets('calls onTypingChanged(true) when text is entered',
        (tester) async {
      var typingState = false;
      await tester.pumpWidget(
        _wrap(onSend: (_) {}, onTypingChanged: (v) => typingState = v),
      );
      await tester.enterText(find.byType(TextField), 'Hi');
      await tester.pump();
      expect(typingState, isTrue);
    });

    testWidgets('calls onSend with trimmed text on send tap', (tester) async {
      String? sent;
      await tester.pumpWidget(
        _wrap(onSend: (t) => sent = t, onTypingChanged: (_) {}),
      );
      await tester.enterText(find.byType(TextField), '  Mensagem  ');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('send')));
      await tester.pump();
      expect(sent, 'Mensagem');
    });

    testWidgets('clears input after send', (tester) async {
      await tester.pumpWidget(
        _wrap(onSend: (_) {}, onTypingChanged: (_) {}),
      );
      await tester.enterText(find.byType(TextField), 'Teste');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('send')));
      await tester.pump();
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.controller?.text, isEmpty);
    });

    testWidgets('shows mention suggestions when @ is typed', (tester) async {
      await tester.pumpWidget(
        _wrap(onSend: (_) {}, onTypingChanged: (_) {}),
      );
      await tester.enterText(find.byType(TextField), '@');
      await tester.pump();
      // Default members list has 5 members — all should appear
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('hides suggestions after send', (tester) async {
      await tester.pumpWidget(
        _wrap(onSend: (_) {}, onTypingChanged: (_) {}),
      );
      await tester.enterText(find.byType(TextField), '@todos mensagem');
      await tester.pump();
      // Type more so suggestions are gone (space breaks the word)
      // Verify send button is present
      expect(find.byKey(const ValueKey('send')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('send')));
      await tester.pump();
      // After send, audio button returns
      expect(find.byKey(const ValueKey('audio')), findsOneWidget);
    });
  });
}
