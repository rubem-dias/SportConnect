import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport_connect/features/feed/data/models/post_model.dart';
import 'package:sport_connect/features/feed/presentation/widgets/post_card.dart';
import 'package:sport_connect/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt')],
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );

PostModel _makePost({
  String content = 'Treino incrível hoje!',
  List<String> mediaUrls = const [],
  Map<String, int> reactions = const {},
  int commentsCount = 0,
  String? userName = 'João Silva',
}) =>
    PostModel(
      id: 'p1',
      userId: 'u1',
      content: content,
      mediaUrls: mediaUrls,
      exerciseData: null,
      prData: null,
      reactions: reactions,
      commentsCount: commentsCount,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      userName: userName,
    );

void main() {
  group('PostCard', () {
    testWidgets('displays post content', (tester) async {
      await tester.pumpWidget(
        _wrap(PostCard(post: _makePost(content: 'Conteúdo do post'))),
      );
      expect(find.text('Conteúdo do post'), findsOneWidget);
    });

    testWidgets('displays user name', (tester) async {
      await tester.pumpWidget(
        _wrap(PostCard(post: _makePost(userName: 'Maria Costa'))),
      );
      expect(find.text('Maria Costa'), findsOneWidget);
    });

    testWidgets('shows reaction emojis', (tester) async {
      await tester.pumpWidget(
        _wrap(PostCard(post: _makePost())),
      );
      // Fire, muscle, trophy emojis are always shown
      expect(find.text('🔥'), findsWidgets);
    });

    testWidgets('shows comment count when > 0', (tester) async {
      await tester.pumpWidget(
        _wrap(PostCard(post: _makePost(commentsCount: 5))),
      );
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('calls onComment callback', (tester) async {
      var commented = false;
      await tester.pumpWidget(
        _wrap(PostCard(
          post: _makePost(),
          onComment: () => commented = true,
        )),
      );
      await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
      expect(commented, isTrue);
    });

    testWidgets('calls onReaction callback when reaction chip tapped',
        (tester) async {
      String? reactedWith;
      await tester.pumpWidget(
        _wrap(PostCard(
          post: _makePost(),
          onReaction: (e) => reactedWith = e,
        )),
      );
      // Tap the first emoji (fire)
      await tester.tap(find.text('🔥').first);
      await tester.pump();
      expect(reactedWith, isNotNull);
    });

    testWidgets('shows reaction count when > 0', (tester) async {
      await tester.pumpWidget(
        _wrap(PostCard(
          post: _makePost(reactions: {'🔥': 3}),
        )),
      );
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders without crashing with empty content', (tester) async {
      await tester.pumpWidget(
        _wrap(PostCard(post: _makePost(content: ''))),
      );
      expect(find.byType(PostCard), findsOneWidget);
    });
  });
}
