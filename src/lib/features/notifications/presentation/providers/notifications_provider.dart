import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/notification_model.dart';

class NotificationsState {
  const NotificationsState({
    required this.notifications,
    required this.isLoading,
  });

  final List<NotificationModel> notifications;
  final bool isLoading;

  int get unreadCount =>
      notifications.where((n) => !n.isRead).length;

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationsNotifier extends Notifier<NotificationsState> {
  @override
  NotificationsState build() {
    _load();
    return const NotificationsState(notifications: [], isLoading: true);
  }

  Future<void> _load() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = NotificationsState(
      notifications: _mockNotifications(),
      isLoading: false,
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = NotificationsState(
      notifications: _mockNotifications(),
      isLoading: false,
    );
  }

  void markAsRead(String id) {
    state = state.copyWith(
      notifications: state.notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList(),
    );
  }

  void markAllAsRead() {
    state = state.copyWith(
      notifications:
          state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }

  static List<NotificationModel> _mockNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'n1',
        type: NotificationType.reaction,
        title: 'Fernanda Lima reagiu ao seu post',
        body: '🔥 no seu treino de peito',
        createdAt: now.subtract(const Duration(minutes: 5)),
        isRead: false,
        actorName: 'Fernanda Lima',
        actorAvatar: 'https://i.pravatar.cc/150?img=5',
      ),
      NotificationModel(
        id: 'n2',
        type: NotificationType.comment,
        title: 'Mateus Corrêa comentou no seu post',
        body: '"Incrível! Que evolução! 💪"',
        createdAt: now.subtract(const Duration(minutes: 20)),
        isRead: false,
        actorName: 'Mateus Corrêa',
        actorAvatar: 'https://i.pravatar.cc/150?img=1',
      ),
      NotificationModel(
        id: 'n3',
        type: NotificationType.follower,
        title: 'Rafael Souza começou a seguir você',
        body: 'Powerlifting • 890 seguidores',
        createdAt: now.subtract(const Duration(hours: 1)),
        isRead: false,
        actorName: 'Rafael Souza',
        actorAvatar: 'https://i.pravatar.cc/150?img=8',
      ),
      NotificationModel(
        id: 'n4',
        type: NotificationType.prBeaten,
        title: 'Bruno Alves bateu um PR!',
        body: 'Agachamento Livre: 185kg — antes era 180kg',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
        actorName: 'Bruno Alves',
        actorAvatar: 'https://i.pravatar.cc/150?img=12',
      ),
      NotificationModel(
        id: 'n5',
        type: NotificationType.mention,
        title: 'Camila Rocha mencionou você',
        body: '"@você é minha inspiração na corrida!"',
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: true,
        actorName: 'Camila Rocha',
        actorAvatar: 'https://i.pravatar.cc/150?img=9',
      ),
      NotificationModel(
        id: 'n6',
        type: NotificationType.reaction,
        title: '12 pessoas reagiram ao seu post',
        body: '🔥 🔥 💪 no PR de supino',
        createdAt: now.subtract(const Duration(hours: 6)),
        isRead: true,
        actorName: 'Fernanda e outros',
        actorAvatar: 'https://i.pravatar.cc/150?img=5',
      ),
      NotificationModel(
        id: 'n7',
        type: NotificationType.groupInvite,
        title: 'Você foi convidado para Powerlifters Brasil',
        body: 'Por Rafael Souza • 3.4k membros',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
        actorName: 'Rafael Souza',
        actorAvatar: 'https://i.pravatar.cc/150?img=8',
      ),
      NotificationModel(
        id: 'n8',
        type: NotificationType.comment,
        title: 'João Victor respondeu seu comentário',
        body: '"Exatamente isso! Consistência é tudo."',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        isRead: true,
        actorName: 'João Victor',
        actorAvatar: 'https://i.pravatar.cc/150?img=15',
      ),
      NotificationModel(
        id: 'n9',
        type: NotificationType.follower,
        title: 'Ana Paula começou a seguir você',
        body: 'Yoga • 4.5k seguidores',
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
        actorName: 'Ana Paula',
        actorAvatar: 'https://i.pravatar.cc/150?img=16',
      ),
    ];
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});
