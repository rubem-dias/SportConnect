import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_loading_skeleton.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../prs/data/models/pr_model.dart';
import '../../data/models/user_profile_model.dart';
import '../providers/profile_providers.dart';
import '../widgets/edit_profile_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedId = userId ?? 'me';
    final profileAsync = ref.watch(profileProvider(resolvedId));

    return profileAsync.when(
      loading: () => const _ProfileSkeleton(),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off_rounded,
                  size: 48, color: AppColors.textDisabledLight),
              const SizedBox(height: AppSpacing.md),
              const Text('Perfil não encontrado'),
              TextButton(
                onPressed: () => ref.invalidate(profileProvider(resolvedId)),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
      data: (profile) => _ProfileBody(
        profile: profile,
        profileId: resolvedId,
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile, required this.profileId});

  final UserProfileModel profile;
  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current =
        ref.watch(profileProvider(profileId)).valueOrNull ?? profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _ProfileSliverHeader(
            profile: current,
            profileId: profileId,
            isDark: isDark,
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.sm),

                // Action buttons (other user only)
                if (!current.isMe) ...[
                  _ActionButtons(profile: current, profileId: profileId),
                  const SizedBox(height: AppSpacing.sm),
                ],

                // Info section
                _InfoSection(profile: current, isDark: isDark),
                const SizedBox(height: AppSpacing.sm),

                // PRs section
                _PRsSection(userId: profileId, isDark: isDark),
                const SizedBox(height: AppSpacing.sm),

                // Badges section
                _BadgesSection(badges: current.badges, isDark: isDark),
                const SizedBox(height: AppSpacing.sm),

                // Settings (own profile)
                if (current.isMe) ...[
                  _SettingsSection(profile: current, profileId: profileId),
                  const SizedBox(height: AppSpacing.sm),

                  // Logout
                  _LogoutSection(),
                ],

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sliver Header ─────────────────────────────────────────────────────────────

class _ProfileSliverHeader extends ConsumerWidget {
  const _ProfileSliverHeader({
    required this.profile,
    required this.profileId,
    required this.isDark,
  });

  final UserProfileModel profile;
  final String profileId;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      surfaceTintColor: Colors.transparent,
      leading: profile.isMe
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
      automaticallyImplyLeading: !profile.isMe,
      actions: [
        if (profile.isMe) ...[
          IconButton(
            icon: const Icon(Icons.qr_code_rounded),
            tooltip: 'Meu QR Code',
            onPressed: () {
              try {
                _showQrSheet(context, profile.username);
              } catch (e) {
                AppSnackbar.error(context, 'Erro ao abrir QR Code');
              }
            },
          ),
          _NotificationsBell(
            onTap: () => context.push(AppRoutes.notifications),
          ),
        ],
        if (!profile.isMe)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) async {
              if (value == 'block') {
                try {
                  await ref
                      .read(profileProvider(profileId).notifier)
                      .blockUser();
                  if (context.mounted) context.pop();
                } catch (_) {
                  // error already shown via globalErrorProvider
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block_rounded, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Bloquear', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 14),
        title: Text(
          profile.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: _HeaderBackground(profile: profile, isDark: isDark),
      ),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground({required this.profile, required this.isDark});

  final UserProfileModel profile;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withAlpha(isDark ? 80 : 50),
                isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Avatar + name
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              _Avatar(avatar: profile.avatar, radius: 52),
              const SizedBox(height: AppSpacing.md),
              Text(
                profile.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                profile.username,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.avatar, required this.radius});

  final String? avatar;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary.withAlpha(40),
        backgroundImage: avatar != null ? NetworkImage(avatar!) : null,
        child: avatar == null
            ? Icon(Icons.person_rounded,
                size: radius * 0.8, color: AppColors.primary)
            : null,
      ),
    );
  }
}

// ── Action buttons (outros usuários) ─────────────────────────────────────────

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({required this.profile, required this.profileId});

  final UserProfileModel profile;
  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current =
        ref.watch(profileProvider(profileId)).valueOrNull ?? profile;

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: current.isFollowing
                    ? OutlinedButton.icon(
                        onPressed: () => ref
                            .read(profileProvider(profileId).notifier)
                            .unfollow(),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Seguindo'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      )
                    : FilledButton.icon(
                        onPressed: () =>
                            ref.read(profileProvider(profileId).notifier).follow(),
                        icon: const Icon(Icons.person_add_rounded, size: 18),
                        label: const Text('Seguir'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push(AppRoutes.chatConversationPath(profileId)),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text('Mensagem'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          if (current.isNearby) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => AppSnackbar.info(
                    context, 'Solicitação enviada para ${current.name}!'),
                icon: const Icon(Icons.fitness_center_rounded, size: 18),
                label: const Text('Treinar junto'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.secondary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Info section ──────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.profile, required this.isDark});

  final UserProfileModel profile;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final hasBio = profile.bio != null && profile.bio!.isNotEmpty;
    final hasSports = profile.sports.isNotEmpty;

    if (!hasBio && !hasSports) return const SizedBox.shrink();

    return _SectionCard(
      isDark: isDark,
      children: [
        if (hasBio)
          _InfoRow(
            icon: Icons.info_outline_rounded,
            isDark: isDark,
            child: Text(
              profile.bio!,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                height: 1.4,
              ),
            ),
          ),
        if (hasBio && hasSports) _Divider(isDark: isDark),
        if (hasSports)
          _InfoRow(
            icon: Icons.sports_rounded,
            isDark: isDark,
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: profile.sports
                  .map((s) => AppBadge(label: s))
                  .toList(),
            ),
          ),
        _Divider(isDark: isDark),
        _InfoRow(
          icon: Icons.trending_up_rounded,
          isDark: isDark,
          child: Text(
            _levelLabel(profile.level),
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  String _levelLabel(String level) {
    switch (level) {
      case 'beginner':
        return 'Iniciante';
      case 'intermediate':
        return 'Intermediário';
      case 'advanced':
        return 'Avançado';
      default:
        return level;
    }
  }
}

// ── PRs section ───────────────────────────────────────────────────────────────

class _PRsSection extends ConsumerWidget {
  const _PRsSection({required this.userId, required this.isDark});

  final String userId;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(userPRsProvider(userId), (_, next) {
      if (next is AsyncError && context.mounted) {
        AppSnackbar.error(context, 'Erro ao carregar PRs');
      }
    });

    final prsAsync = ref.watch(userPRsProvider(userId));

    return prsAsync.when(
      loading: () => _SectionCard(
        isDark: isDark,
        header: _SectionHeader(
            title: 'Melhores PRs', icon: Icons.emoji_events_rounded, isDark: isDark),
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                const AppLoadingSkeleton(width: 40, height: 40, borderRadius: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppLoadingSkeleton(height: 13, borderRadius: 4),
                      const SizedBox(height: 5),
                      AppLoadingSkeleton(
                          width: 80, height: 11, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (prs) {
        if (prs.isEmpty) return const SizedBox.shrink();
        final preview = prs.take(3).toList();
        return _SectionCard(
          isDark: isDark,
          header: _SectionHeader(
              title: 'Melhores PRs',
              icon: Icons.emoji_events_rounded,
              isDark: isDark),
          children: [
            ...preview.map((s) => _PRRow(pr: s, isDark: isDark)),
            if (prs.length > 3)
              _SeeMoreTile(
                label: 'Ver todos os PRs',
                isDark: isDark,
                onTap: () => context.push(AppRoutes.prs),
              ),
          ],
        );
      },
    );
  }
}

class _PRRow extends StatelessWidget {
  const _PRRow({required this.pr, required this.isDark});

  final ExercisePRSummary pr;
  final bool isDark;

  String _muscleEmoji(String group) {
    switch (group.toLowerCase()) {
      case 'peito':
        return '💪';
      case 'costas':
        return '🔙';
      case 'pernas':
        return '🦵';
      case 'ombro':
        return '🏋️';
      case 'cardio':
        return '🏃';
      default:
        return '💪';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 2),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primary.withAlpha(30),
        child: Text(_muscleEmoji(pr.muscleGroup),
            style: const TextStyle(fontSize: 16)),
      ),
      title: Text(
        pr.exerciseName,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        pr.muscleGroup,
        style: TextStyle(
          fontSize: 12,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            pr.bestPR.displayValue,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 15,
            ),
          ),
          if (pr.isRecentPR)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.prGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Novo!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Badges section ────────────────────────────────────────────────────────────

class _BadgesSection extends StatelessWidget {
  const _BadgesSection({required this.badges, required this.isDark});

  final List<BadgeModel> badges;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();

    final unlocked = badges.where((b) => b.isUnlocked).toList();
    final locked = badges.where((b) => !b.isUnlocked).toList();
    final sorted = [...unlocked, ...locked];

    return _SectionCard(
      isDark: isDark,
      header: _SectionHeader(
        title: 'Conquistas',
        icon: Icons.military_tech_rounded,
        isDark: isDark,
        trailing: '${unlocked.length}/${badges.length}',
      ),
      children: [
        SizedBox(
          height: 96,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            scrollDirection: Axis.horizontal,
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) =>
                _BadgeChip(badge: sorted[i], isDark: isDark, onTap: () => _showBadgeInfo(context, sorted[i])),
          ),
        ),
      ],
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip(
      {required this.badge, required this.isDark, required this.onTap});

  final BadgeModel badge;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: badge.isUnlocked ? 1 : 0.35,
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: 72,
          decoration: BoxDecoration(
            color: badge.isUnlocked
                ? AppColors.primary.withAlpha(20)
                : (isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight),
            borderRadius: BorderRadius.circular(12),
            border: badge.isUnlocked
                ? Border.all(color: AppColors.primary.withAlpha(80))
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(badge.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  badge.title,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: badge.isUnlocked
                        ? (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight)
                        : (isDark
                            ? AppColors.textDisabledDark
                            : AppColors.textDisabledLight),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showBadgeInfo(BuildContext context, BadgeModel badge) {
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Row(
        children: [
          Text(badge.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(badge.title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(badge.description),
          if (badge.isUnlocked && badge.unlockedAt != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Desbloqueado em '
              '${badge.unlockedAt!.day.toString().padLeft(2, '0')}/'
              '${badge.unlockedAt!.month.toString().padLeft(2, '0')}/'
              '${badge.unlockedAt!.year}',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ] else if (!badge.isUnlocked)
            const Text(
              'Ainda bloqueado',
              style: TextStyle(color: AppColors.textDisabledLight),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    ),
  );
}

// ── Settings section (own profile) ───────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.profile, required this.profileId});

  final UserProfileModel profile;
  final String profileId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _SectionCard(
      isDark: isDark,
      children: [
        _SettingsTile(
          icon: Icons.edit_rounded,
          label: 'Editar perfil',
          isDark: isDark,
          onTap: () => showEditProfileSheet(context, profile, profileId),
        ),
        _Divider(isDark: isDark),
        _SettingsTile(
          icon: Icons.notifications_outlined,
          label: 'Notificações',
          isDark: isDark,
          onTap: () => context.push(AppRoutes.notificationSettings),
        ),
        _Divider(isDark: isDark),
        _SettingsTile(
          icon: Icons.qr_code_rounded,
          label: 'Meu QR Code',
          isDark: isDark,
          onTap: () {
            try {
              _showQrSheet(context, profile.username);
            } catch (e) {
              AppSnackbar.error(context, 'Erro ao abrir QR Code');
            }
          },
        ),
      ],
    );
  }
}

// ── Logout ────────────────────────────────────────────────────────────────────

class _LogoutSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _SectionCard(
      isDark: isDark,
      children: [
        _SettingsTile(
          icon: Icons.logout_rounded,
          label: 'Sair',
          color: AppColors.error,
          isDark: isDark,
          onTap: () => _confirmLogout(context, ref),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authStateProvider.notifier).logout();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

// ── Shared building blocks ────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.isDark,
    required this.children,
    this.header,
  });

  final bool isDark;
  final List<Widget> children;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) header!,
          ...children,
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isDark,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final bool isDark;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon,
              size: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight),
          const SizedBox(width: AppSpacing.xs),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              letterSpacing: 0.5,
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            Text(
              trailing!,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.isDark, required this.child});

  final IconData icon;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 20,
              color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: 22, color: effectiveColor),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: effectiveColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (color == null)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
          ],
        ),
      ),
    );
  }
}

class _SeeMoreTile extends StatelessWidget {
  const _SeeMoreTile(
      {required this.label, required this.isDark, required this.onTap});

  final String label;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: AppSpacing.lg + 20 + AppSpacing.md,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }
}

// ── QR Code sheet ─────────────────────────────────────────────────────────────

void _showQrSheet(BuildContext context, String username) {
  if (username.isEmpty) {
    AppSnackbar.error(context, 'Username não disponível');
    return;
  }

  final isDark = Theme.of(context).brightness == Brightness.dark;
  final handle = username.startsWith('@') ? username : '@$username';
  final qrData = 'sportconnect://u/$handle';

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    // builder recebe o sheetContext para SafeArea e viewPadding corretos
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Meu QR Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  size: 220,
                  errorStateBuilder: (_, error) => SizedBox(
                    width: 220,
                    height: 220,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.qr_code_2_rounded,
                              size: 48, color: AppColors.textDisabledLight),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Erro ao gerar QR Code',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF5C6BC0),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                handle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Aponte a câmera para adicionar no SportConnect',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(sheetContext);
                        try {
                          await Clipboard.setData(
                              ClipboardData(text: handle));
                          if (context.mounted) {
                            AppSnackbar.success(context, 'Username copiado!');
                          }
                        } catch (_) {
                          if (context.mounted) {
                            AppSnackbar.error(
                                context, 'Erro ao copiar username');
                          }
                        }
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copiar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Compartilhar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    ),
  );
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Column(
        children: [
          // Header skeleton
          Container(
            height: 260,
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  const AppLoadingSkeleton(
                      width: 104, height: 104, borderRadius: 52),
                  const SizedBox(height: AppSpacing.md),
                  const AppLoadingSkeleton(
                      width: 160, height: 20, borderRadius: 6),
                  const SizedBox(height: 6),
                  AppLoadingSkeleton(
                      width: 100, height: 14, borderRadius: 4),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md),
                    child: Row(
                      children: [
                        const AppLoadingSkeleton(
                            width: 20, height: 20, borderRadius: 10),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppLoadingSkeleton(
                              height: 14, borderRadius: 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notifications bell ────────────────────────────────────────────────────────

class _NotificationsBell extends ConsumerWidget {
  const _NotificationsBell({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unreadNotificationsCountProvider);
    return IconButton(
      onPressed: onTap,
      icon: Badge(
        isLabelVisible: count > 0,
        label: count > 9 ? const Text('9+') : Text('$count'),
        backgroundColor: AppColors.error,
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
