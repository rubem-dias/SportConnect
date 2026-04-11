import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../data/models/conversation_model.dart';

class GroupInfoScreen extends ConsumerStatefulWidget {
  const GroupInfoScreen({
    required this.conversation,
    super.key,
  });

  final ConversationModel conversation;

  @override
  ConsumerState<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends ConsumerState<GroupInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isChannel =
        widget.conversation.type == ConversationType.channel;
    final members = widget.conversation.members;
    final currentUserIsAdmin = members
        .where((m) => m.userId == 'me')
        .any((m) => m.isAdmin);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            surfaceTintColor: Colors.transparent,
            actions: [
              if (currentUserIsAdmin)
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => _showEditDialog(context, isDark),
                ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                onPressed: () => _showOptions(context, isDark),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _GroupHeader(
                conversation: widget.conversation,
                isChannel: isChannel,
                isDark: isDark,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _GroupStats(
              memberCount: members.isNotEmpty
                  ? members.length
                  : (isChannel ? 3400 : 5),
              isChannel: isChannel,
              isDark: isDark,
            ),
          ),
          if (!isChannel)
            SliverToBoxAdapter(
              child: _InviteSection(
                conversationId: widget.conversation.id,
                isDark: isDark,
              ),
            ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Membros'),
                  Tab(text: 'Mídia'),
                ],
              ),
              isDark: isDark,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _MembersTab(
              conversation: widget.conversation,
              currentUserIsAdmin: currentUserIsAdmin,
              isChannel: isChannel,
              isDark: isDark,
            ),
            _MediaTab(isDark: isDark),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, bool isDark) {
    showDialog<void>(
      context: context,
      builder: (_) => _EditGroupDialog(
        conversation: widget.conversation,
        isDark: isDark,
      ),
    );
  }

  void _showOptions(BuildContext context, bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor:
          isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off_outlined),
              title: const Text('Silenciar notificações'),
              onTap: () {
                ctx.pop();
                AppSnackbar.show(context, message: 'Grupo silenciado');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.exit_to_app_rounded,
                color: AppColors.error,
              ),
              title: const Text(
                'Sair do grupo',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                ctx.pop();
                context.pop();
                AppSnackbar.show(context,
                    message: 'Você saiu do grupo');
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

// ─── Group Header ─────────────────────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.conversation,
    required this.isChannel,
    required this.isDark,
  });

  final ConversationModel conversation;
  final bool isChannel;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 44,
            backgroundImage: conversation.avatar != null
                ? NetworkImage(conversation.avatar!)
                : null,
            backgroundColor: AppColors.primary.withAlpha(30),
            child: conversation.avatar == null
                ? Icon(
                    isChannel
                        ? Icons.campaign_rounded
                        : Icons.group_rounded,
                    size: 40,
                    color: AppColors.primary,
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            conversation.name,
            style: AppTypography.titleLarge.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isChannel ? 'Canal' : 'Grupo',
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─── Group Stats ──────────────────────────────────────────────────────────────

class _GroupStats extends StatelessWidget {
  const _GroupStats({
    required this.memberCount,
    required this.isChannel,
    required this.isDark,
  });

  final int memberCount;
  final bool isChannel;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final label = isChannel ? 'assinantes' : 'membros';
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StatItem(
            value: '$memberCount',
            label: label,
            icon: Icons.people_rounded,
            isDark: isDark,
          ),
          const SizedBox(width: AppSpacing.xxl),
          _StatItem(
            value: '128',
            label: 'mensagens',
            icon: Icons.chat_bubble_rounded,
            isDark: isDark,
          ),
          const SizedBox(width: AppSpacing.xxl),
          _StatItem(
            value: '23',
            label: 'fotos',
            icon: Icons.photo_library_rounded,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.isDark,
  });

  final String value;
  final String label;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

// ─── Invite Section ───────────────────────────────────────────────────────────

class _InviteSection extends StatelessWidget {
  const _InviteSection({
    required this.conversationId,
    required this.isDark,
  });

  final String conversationId;
  final bool isDark;

  String get _inviteLink => 'sportconnect://join/$conversationId';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Row(
        children: [
          const Icon(Icons.link_rounded, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Link de convite',
                  style: AppTypography.titleSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  _inviteLink,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: AppColors.primary),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _inviteLink));
              AppSnackbar.show(context, message: 'Link copiado!');
            },
          ),
        ],
      ),
    );
  }
}

// ─── Members Tab ──────────────────────────────────────────────────────────────

class _MembersTab extends StatelessWidget {
  const _MembersTab({
    required this.conversation,
    required this.currentUserIsAdmin,
    required this.isChannel,
    required this.isDark,
  });

  final ConversationModel conversation;
  final bool currentUserIsAdmin;
  final bool isChannel;
  final bool isDark;

  List<ConversationMember> get _members {
    if (conversation.members.isNotEmpty) return conversation.members;
    return const [
      ConversationMember(
        userId: 'me',
        name: 'Você',
        avatar: 'https://i.pravatar.cc/150?img=3',
        isAdmin: true,
        isOnline: true,
      ),
      ConversationMember(
        userId: 'u1',
        name: 'Mateus Corrêa',
        avatar: 'https://i.pravatar.cc/150?img=1',
        isOnline: true,
      ),
      ConversationMember(
        userId: 'u2',
        name: 'Fernanda Lima',
        avatar: 'https://i.pravatar.cc/150?img=5',
      ),
      ConversationMember(
        userId: 'u3',
        name: 'Rafael Souza',
        avatar: 'https://i.pravatar.cc/150?img=8',
      ),
      ConversationMember(
        userId: 'u4',
        name: 'Camila Rocha',
        avatar: 'https://i.pravatar.cc/150?img=9',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final members = _members;

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: members.length + (currentUserIsAdmin ? 1 : 0),
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
        indent: AppSpacing.xxxl + AppSpacing.md,
      ),
      itemBuilder: (context, index) {
        if (index == 0 && currentUserIsAdmin) {
          return ListTile(
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withAlpha(20),
              child: const Icon(
                Icons.person_add_rounded,
                color: AppColors.primary,
              ),
            ),
            title: Text(
              'Adicionar membro',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            onTap: () {},
          );
        }

        final member =
            members[currentUserIsAdmin ? index - 1 : index];
        return _MemberTile(
          member: member,
          currentUserIsAdmin: currentUserIsAdmin,
          isDark: isDark,
        );
      },
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.currentUserIsAdmin,
    required this.isDark,
  });

  final ConversationMember member;
  final bool currentUserIsAdmin;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: member.avatar != null
                ? NetworkImage(member.avatar!)
                : null,
            backgroundColor: isDark
                ? AppColors.surfaceVariantDark
                : AppColors.surfaceVariantLight,
            child: member.avatar == null
                ? const Icon(Icons.person_rounded)
                : null,
          ),
          if (member.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.online,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        member.userId == 'me' ? 'Você' : member.name,
        style: AppTypography.titleSmall.copyWith(
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: member.isAdmin
          ? Text(
              'Admin',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            )
          : null,
      trailing: currentUserIsAdmin && member.userId != 'me'
          ? PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              onSelected: (value) {
                if (value == 'admin') {
                  AppSnackbar.show(
                    context,
                    message: '${member.name} é agora admin',
                  );
                } else if (value == 'remove') {
                  AppSnackbar.show(
                    context,
                    message: '${member.name} foi removido do grupo',
                    type: AppSnackbarType.error,
                  );
                }
              },
              itemBuilder: (_) => [
                if (!member.isAdmin)
                  const PopupMenuItem(
                    value: 'admin',
                    child: Text('Tornar admin'),
                  ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text(
                    'Remover do grupo',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            )
          : null,
    );
  }
}

// ─── Media Tab ────────────────────────────────────────────────────────────────

class _MediaTab extends StatelessWidget {
  const _MediaTab({required this.isDark});

  final bool isDark;

  static const _urls = [
    'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400',
    'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400',
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
    'https://images.unsplash.com/photo-1566241142559-40e1dab266c6?w=400',
    'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=400',
    'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?w=400',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.xs),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: _urls.length,
      itemBuilder: (_, i) => Image.network(
        _urls[i],
        fit: BoxFit.cover,
      ),
    );
  }
}

// ─── Edit Dialog ──────────────────────────────────────────────────────────────

class _EditGroupDialog extends StatefulWidget {
  const _EditGroupDialog({
    required this.conversation,
    required this.isDark,
  });

  final ConversationModel conversation;
  final bool isDark;

  @override
  State<_EditGroupDialog> createState() => _EditGroupDialogState();
}

class _EditGroupDialogState extends State<_EditGroupDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.conversation.name);
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDark
          ? AppColors.surfaceDark
          : AppColors.surfaceLight,
      title: const Text('Editar grupo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome do grupo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Descrição',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            context.pop();
            AppSnackbar.show(
              context,
              message: 'Grupo atualizado!',
            );
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

// ─── Tab Bar Delegate ─────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(this.tabBar, {required this.isDark});

  final TabBar tabBar;
  final bool isDark;

  @override
  double get minExtent => tabBar.preferredSize.height + 1;

  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Column(
        children: [
          tabBar,
          Divider(
            height: 1,
            color:
                isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
