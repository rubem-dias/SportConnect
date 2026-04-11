import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Configurações de notificações',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      body: ListView(
        children: [
          _SectionHeader(
            label: 'ATIVIDADE SOCIAL',
            isDark: isDark,
          ),
          _NotificationToggleTile(
            type: NotificationType.reaction,
            label: 'Reactions nos seus posts',
            subtitle: 'Quando alguém reagir a um post seu',
            icon: Icons.favorite_rounded,
            iconColor: AppColors.error,
            enabled: settings[NotificationType.reaction] ?? true,
            isDark: isDark,
            onChanged: () => ref
                .read(notificationSettingsProvider.notifier)
                .toggle(NotificationType.reaction),
          ),
          _NotificationToggleTile(
            type: NotificationType.comment,
            label: 'Comentários',
            subtitle: 'Quando alguém comentar nos seus posts',
            icon: Icons.chat_bubble_rounded,
            iconColor: AppColors.info,
            enabled: settings[NotificationType.comment] ?? true,
            isDark: isDark,
            onChanged: () => ref
                .read(notificationSettingsProvider.notifier)
                .toggle(NotificationType.comment),
          ),
          _NotificationToggleTile(
            type: NotificationType.mention,
            label: 'Menções',
            subtitle: 'Quando alguém mencionar você em um post ou comentário',
            icon: Icons.alternate_email_rounded,
            iconColor: AppColors.primary,
            enabled: settings[NotificationType.mention] ?? true,
            isDark: isDark,
            onChanged: () => ref
                .read(notificationSettingsProvider.notifier)
                .toggle(NotificationType.mention),
          ),
          _NotificationToggleTile(
            type: NotificationType.follower,
            label: 'Novos seguidores',
            subtitle: 'Quando alguém começar a seguir você',
            icon: Icons.person_add_rounded,
            iconColor: AppColors.success,
            enabled: settings[NotificationType.follower] ?? true,
            isDark: isDark,
            onChanged: () => ref
                .read(notificationSettingsProvider.notifier)
                .toggle(NotificationType.follower),
          ),
          Divider(
            height: 1,
            indent: AppSpacing.lg,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          _SectionHeader(
            label: 'CONQUISTAS',
            isDark: isDark,
          ),
          _NotificationToggleTile(
            type: NotificationType.prBeaten,
            label: 'PRs de amigos',
            subtitle: 'Quando alguém que você segue bater um novo record',
            icon: Icons.emoji_events_rounded,
            iconColor: AppColors.warning,
            enabled: settings[NotificationType.prBeaten] ?? true,
            isDark: isDark,
            onChanged: () => ref
                .read(notificationSettingsProvider.notifier)
                .toggle(NotificationType.prBeaten),
          ),
          Divider(
            height: 1,
            indent: AppSpacing.lg,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          _SectionHeader(
            label: 'GRUPOS E CANAIS',
            isDark: isDark,
          ),
          _NotificationToggleTile(
            type: NotificationType.groupInvite,
            label: 'Convites para grupos',
            subtitle: 'Quando alguém convidar você para um grupo ou canal',
            icon: Icons.group_add_rounded,
            iconColor: AppColors.secondary,
            enabled: settings[NotificationType.groupInvite] ?? true,
            isDark: isDark,
            onChanged: () => ref
                .read(notificationSettingsProvider.notifier)
                .toggle(NotificationType.groupInvite),
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Essas configurações controlam as notificações dentro do app. '
              'Para gerenciar notificações push do sistema, acesse as '
              'configurações do seu dispositivo.',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

class _NotificationToggleTile extends StatelessWidget {
  const _NotificationToggleTile({
    required this.type,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.enabled,
    required this.isDark,
    required this.onChanged,
  });

  final NotificationType type;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool enabled;
  final bool isDark;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: enabled,
      onChanged: (_) => onChanged(),
      activeThumbColor: AppColors.primary,
      activeTrackColor: AppColors.primary.withAlpha(80),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}
