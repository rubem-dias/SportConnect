import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport_connect/features/chat/data/models/chat_message_model.dart';
import 'package:sport_connect/features/chat/presentation/widgets/message_bubble.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          child: child,
        ),
      ),
    );

ChatMessageModel _makeMessage({
  String id = 'm1',
  String senderId = 'other',
  String senderName = 'Fernanda',
  String content = 'Olá!',
}) =>
    ChatMessageModel(
      id: id,
      conversationId: 'c1',
      senderId: senderId,
      senderName: senderName,
      content: content,
      createdAt: DateTime(2024, 6, 1, 10, 30),
    );

void main() {
  group('MessageBubble', () {
    testWidgets('shows message content', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MessageBubble(
            message: _makeMessage(content: 'Bom treino!'),
            isMe: false,
            showSenderName: false,
          ),
        ),
      );
      expect(find.text('Bom treino!'), findsOneWidget);
    });

    testWidgets('aligns right when isMe is true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MessageBubble(
            message: _makeMessage(senderId: 'me'),
            isMe: true,
            showSenderName: false,
          ),
        ),
      );
      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('aligns left when isMe is false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MessageBubble(
            message: _makeMessage(),
            isMe: false,
            showSenderName: false,
          ),
        ),
      );
      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('shows sender name when showSenderName is true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MessageBubble(
            message: _makeMessage(),
            isMe: false,
            showSenderName: true,
          ),
        ),
      );
      expect(find.text('Fernanda'), findsOneWidget);
    });

    testWidgets('hides sender name when showSenderName is false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MessageBubble(
            message: _makeMessage(),
            isMe: false,
            showSenderName: false,
          ),
        ),
      );
      expect(find.text('Fernanda'), findsNothing);
    });

    testWidgets('calls onLongPress callback', (tester) async {
      var longPressed = false;
      await tester.pumpWidget(
        _wrap(
          MessageBubble(
            message: _makeMessage(),
            isMe: false,
            showSenderName: false,
            onLongPress: () => longPressed = true,
          ),
        ),
      );
      await tester.longPress(find.text('Olá!'));
      expect(longPressed, isTrue);
    });
  });
}
