import '../../features/feed/data/models/post_model.dart';
import '../../features/feed/domain/repositories/feed_repository.dart';

class MockFeedRepository implements FeedRepository {
  static final _page1 = _buildPage1();
  static final _page2 = _buildPage2();

  @override
  Future<PostModel> createPost({
    required String content,
    List<String> mediaUrls = const [],
    String? prId,
    String privacy = 'everyone',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return PostModel(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'me',
      content: content,
      mediaUrls: mediaUrls,
      exerciseData: null,
      prData: null,
      reactions: const {},
      commentsCount: 0,
      createdAt: DateTime.now(),
      userName: 'Você',
    );
  }

  @override
  Future<void> reactToPost({required String postId, required String emoji}) async {}

  @override
  Future<void> removeReaction({required String postId, required String emoji}) async {}

  @override
  Future<FeedPage> fetchFeed({String? cursor, int limit = 20}) async {
    // Simula latência de rede
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (cursor == 'page2') return FeedPage(posts: _page2, nextCursor: null);
    return FeedPage(posts: _page1, nextCursor: 'page2');
  }

  static List<PostModel> _buildPage1() {
    final now = DateTime.now();
    return [
      // Post normal com foto
      PostModel(
        id: '1',
        userId: 'u1',
        userName: 'Mateus Corrêa',
        userAvatar: null,
        content:
            'Treino de peito concluído 🔥 Batendo 120kg no supino pela primeira vez! A consistência está valendo.',
        mediaUrls: [
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
        ],
        reactions: {'🔥': 14, '💪': 8, '🏆': 2},
        commentsCount: 5,
        createdAt: now.subtract(const Duration(hours: 2)),
        exerciseData: null,
        prData: null,
      ),

      // PR — supino
      PostModel(
        id: '2',
        userId: 'u2',
        userName: 'Fernanda Lima',
        userAvatar: null,
        content: 'SUPINO 120KG! Nunca pensei que chegaria aqui. Gratidão ao @coach_paulo!',
        mediaUrls: [],
        reactions: {'🔥': 31, '💪': 22, '🏆': 15},
        commentsCount: 12,
        createdAt: now.subtract(const Duration(hours: 5)),
        exerciseData: null,
        prData: {
          'exercise': 'Supino Reto',
          'value': '120',
          'unit': 'kg',
          'reps': 1,
        },
      ),

      // Post normal com múltiplas fotos
      PostModel(
        id: '3',
        userId: 'u3',
        userName: 'Rafael Souza',
        userAvatar: null,
        content:
            'Semana de treinos intensa! Consegui bater minhas metas de volume essa semana. '
            'Continuando com a periodização que o coach passou. Foco total no campeonato de novembro.',
        mediaUrls: [
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800',
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800',
        ],
        reactions: {'🔥': 6, '💪': 3},
        commentsCount: 2,
        createdAt: now.subtract(const Duration(hours: 8)),
        exerciseData: null,
        prData: null,
      ),

      // PR — corrida
      PostModel(
        id: '4',
        userId: 'u4',
        userName: 'Camila Rocha',
        userAvatar: null,
        content: 'Sub-20 minutos nos 5km! Meta de 2024 cumprida 🏃‍♀️',
        mediaUrls: [],
        reactions: {'🔥': 45, '💪': 30, '🏆': 20},
        commentsCount: 18,
        createdAt: now.subtract(const Duration(hours: 12)),
        exerciseData: null,
        prData: {
          'exercise': '5km',
          'value': '19',
          'unit': 'min',
        },
      ),

      // Post sem foto, texto longo
      PostModel(
        id: '5',
        userId: 'u5',
        userName: 'João Victor',
        userAvatar: null,
        content:
            'Reflexão do dia: muita gente desiste quando as coisas ficam difíceis. '
            'Mas é exatamente nesse momento que o progresso acontece. '
            'Passei os últimos 6 meses treinando com consistência mesmo quando não tinha vontade. '
            'Resultado: -12kg e bati todos os meus PRs de força. '
            'Não existe segredo, existe trabalho.',
        mediaUrls: [],
        reactions: {'🔥': 88, '💪': 55},
        commentsCount: 34,
        createdAt: now.subtract(const Duration(hours: 20)),
        exerciseData: null,
        prData: null,
      ),

      // PR — agachamento com 4 fotos
      PostModel(
        id: '6',
        userId: 'u6',
        userName: 'Bruno Alves',
        userAvatar: null,
        content: 'Agachamento 180kg! Esse foi pesado mas saiu limpo.',
        mediaUrls: [
          'https://images.unsplash.com/photo-1566241142559-40e1dab266c6?w=800',
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800',
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800',
          'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?w=800',
        ],
        reactions: {'🔥': 102, '💪': 78, '🏆': 41},
        commentsCount: 27,
        createdAt: now.subtract(const Duration(days: 1)),
        exerciseData: null,
        prData: {
          'exercise': 'Agachamento Livre',
          'value': '180',
          'unit': 'kg',
          'reps': 1,
        },
      ),
    ];
  }

  static List<PostModel> _buildPage2() {
    final now = DateTime.now();
    return [
      PostModel(
        id: '7',
        userId: 'u7',
        userName: 'Ana Paula',
        userAvatar: null,
        content: 'Yoga + corrida leve hoje. Recuperação ativa é parte do treino também!',
        mediaUrls: [
          'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800',
        ],
        reactions: {'🔥': 12, '💪': 5},
        commentsCount: 3,
        createdAt: now.subtract(const Duration(days: 2)),
        exerciseData: null,
        prData: null,
      ),
      PostModel(
        id: '8',
        userId: 'u8',
        userName: 'Carlos Mendes',
        userAvatar: null,
        content: 'Deadlift 200kg. Próxima meta: 220.',
        mediaUrls: [],
        reactions: {'🔥': 77, '💪': 60, '🏆': 35},
        commentsCount: 22,
        createdAt: now.subtract(const Duration(days: 2, hours: 4)),
        exerciseData: null,
        prData: {
          'exercise': 'Levantamento Terra',
          'value': '200',
          'unit': 'kg',
          'reps': 1,
        },
      ),
    ];
  }
}
