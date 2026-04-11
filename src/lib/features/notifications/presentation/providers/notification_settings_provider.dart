import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/notification_model.dart';

/// Persists which notification types the user wants to receive.
/// Backed by a simple in-memory map (Hive persistence can be wired later).
class NotificationSettingsNotifier
    extends Notifier<Map<NotificationType, bool>> {
  @override
  Map<NotificationType, bool> build() {
    // All types enabled by default.
    return {for (final t in NotificationType.values) t: true};
  }

  void toggle(NotificationType type) {
    state = {...state, type: !(state[type] ?? true)};
  }

  bool isEnabled(NotificationType type) => state[type] ?? true;
}

final notificationSettingsProvider = NotifierProvider<
    NotificationSettingsNotifier, Map<NotificationType, bool>>(
  NotificationSettingsNotifier.new,
);
