import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../data/models/conversation_model.dart';

Future<void> showCreateGroupSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CreateGroupSheet(),
  );
}

class _CreateGroupSheet extends ConsumerStatefulWidget {
  const _CreateGroupSheet();

  @override
  ConsumerState<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends ConsumerState<_CreateGroupSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPrivate = false;
  bool _isChannel = false;
  String _selectedSport = 'Musculação';
  bool _isLoading = false;
  int _step = 0;

  final _sports = [
    'Musculação',
    'CrossFit',
    'Corrida',
    'Ciclismo',
    'Natação',
    'Yoga',
    'Powerlifting',
    'Calistenia',
    'Artes Marciais',
    'Futebol',
    'Basquete',
    'Voleibol',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Criar grupo',
                      style: AppTypography.titleLarge.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Step indicator
                  Text(
                    '${_step + 1}/2',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar
            LinearProgressIndicator(
              value: (_step + 1) / 2,
              backgroundColor: isDark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),

            Expanded(
              child: Form(
                key: _formKey,
                child: _step == 0
                    ? _StepOne(
                        controller: scrollController,
                        nameController: _nameController,
                        descController: _descController,
                        isPrivate: _isPrivate,
                        isChannel: _isChannel,
                        selectedSport: _selectedSport,
                        sports: _sports,
                        isDark: isDark,
                        onPrivateChanged: (v) =>
                            setState(() => _isPrivate = v),
                        onChannelChanged: (v) =>
                            setState(() => _isChannel = v),
                        onSportChanged: (v) =>
                            setState(() => _selectedSport = v),
                      )
                    : _StepTwo(
                        controller: scrollController,
                        isDark: isDark,
                        groupName: _nameController.text,
                      ),
              ),
            ),

            // Action buttons
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg +
                    MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: AppButton(
                        label: 'Voltar',
                        variant: AppButtonVariant.ghost,
                        onPressed: () => setState(() => _step--),
                      ),
                    ),
                  if (_step > 0)
                    const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: _step == 0 ? 'Próximo' : 'Criar grupo',
                      isLoading: _isLoading,
                      onPressed: _step == 0 ? _nextStep : _createGroup,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _step = 1);
    }
  }

  Future<void> _createGroup() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);

    if (!mounted) return;

    // Create a mock conversation and navigate to it
    final newConv = ConversationModel(
      id: 'group_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      type: _isChannel ? ConversationType.channel : ConversationType.group,
      lastMessage: 'Grupo criado',
      lastMessageAt: DateTime.now(),
    );

    context.pop(); // close sheet
    AppSnackbar.show(
      context,
      message: 'Grupo "${newConv.name}" criado!',
      type: AppSnackbarType.success,
    );

    context.push(
      AppRoutes.chatConversationPath(newConv.id),
      extra: newConv,
    );
  }
}

// ─── Step 1: Info ─────────────────────────────────────────────────────────────

class _StepOne extends StatelessWidget {
  const _StepOne({
    required this.controller,
    required this.nameController,
    required this.descController,
    required this.isPrivate,
    required this.isChannel,
    required this.selectedSport,
    required this.sports,
    required this.isDark,
    required this.onPrivateChanged,
    required this.onChannelChanged,
    required this.onSportChanged,
  });

  final ScrollController controller;
  final TextEditingController nameController;
  final TextEditingController descController;
  final bool isPrivate;
  final bool isChannel;
  final String selectedSport;
  final List<String> sports;
  final bool isDark;
  final ValueChanged<bool> onPrivateChanged;
  final ValueChanged<bool> onChannelChanged;
  final ValueChanged<String> onSportChanged;

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final hintColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Group avatar placeholder
        Center(
          child: GestureDetector(
            onTap: () {},
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary.withAlpha(20),
                  child: const Icon(
                    Icons.group_rounded,
                    size: 44,
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Name
        TextFormField(
          controller: nameController,
          style: AppTypography.bodyLarge.copyWith(color: textColor),
          decoration: InputDecoration(
            labelText: 'Nome do grupo *',
            labelStyle: TextStyle(color: hintColor),
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Informe o nome do grupo'
              : null,
        ),
        const SizedBox(height: AppSpacing.md),

        // Description
        TextFormField(
          controller: descController,
          maxLines: 3,
          style: AppTypography.bodyLarge.copyWith(color: textColor),
          decoration: InputDecoration(
            labelText: 'Descrição (opcional)',
            labelStyle: TextStyle(color: hintColor),
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Sport
        DropdownButtonFormField<String>(
          initialValue: selectedSport,
          style: AppTypography.bodyLarge.copyWith(color: textColor),
          dropdownColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          decoration: InputDecoration(
            labelText: 'Esporte principal',
            labelStyle: TextStyle(color: hintColor),
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          items: sports
              .map(
                (s) => DropdownMenuItem(value: s, child: Text(s)),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onSportChanged(v);
          },
        ),
        const SizedBox(height: AppSpacing.xl),

        // Private toggle
        SwitchListTile(
          value: isPrivate,
          onChanged: onPrivateChanged,
          activeThumbColor: AppColors.primary,
          title: Text(
            'Grupo privado',
            style: AppTypography.bodyMedium.copyWith(color: textColor),
          ),
          subtitle: Text(
            'Apenas por convite',
            style: AppTypography.bodySmall.copyWith(color: hintColor),
          ),
        ),

        // Channel toggle
        SwitchListTile(
          value: isChannel,
          onChanged: onChannelChanged,
          activeThumbColor: AppColors.primary,
          title: Text(
            'Canal (broadcast)',
            style: AppTypography.bodyMedium.copyWith(color: textColor),
          ),
          subtitle: Text(
            'Somente admins escrevem',
            style: AppTypography.bodySmall.copyWith(color: hintColor),
          ),
        ),
      ],
    );
  }
}

// ─── Step 2: Members ─────────────────────────────────────────────────────────

class _StepTwo extends StatefulWidget {
  const _StepTwo({
    required this.controller,
    required this.isDark,
    required this.groupName,
  });

  final ScrollController controller;
  final bool isDark;
  final String groupName;

  @override
  State<_StepTwo> createState() => _StepTwoState();
}

class _StepTwoState extends State<_StepTwo> {
  final _selected = <String>{};

  static const _contacts = [
    (id: 'u1', name: 'Mateus Corrêa', avatar: 'https://i.pravatar.cc/150?img=1'),
    (id: 'u2', name: 'Fernanda Lima', avatar: 'https://i.pravatar.cc/150?img=5'),
    (id: 'u3', name: 'Rafael Souza', avatar: 'https://i.pravatar.cc/150?img=8'),
    (id: 'u4', name: 'Camila Rocha', avatar: 'https://i.pravatar.cc/150?img=9'),
    (id: 'u5', name: 'Bruno Alves', avatar: 'https://i.pravatar.cc/150?img=12'),
    (id: 'u6', name: 'Ana Paula', avatar: 'https://i.pravatar.cc/150?img=16'),
    (id: 'u7', name: 'João Victor', avatar: 'https://i.pravatar.cc/150?img=15'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Text(
            'Adicionar membros para "${widget.groupName}"',
            style: AppTypography.bodyMedium.copyWith(color: subtitleColor),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: widget.controller,
            itemCount: _contacts.length,
            itemBuilder: (context, index) {
              final c = _contacts[index];
              final isSelected = _selected.contains(c.id);
              return ListTile(
                leading: CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(c.avatar),
                ),
                title: Text(
                  c.name,
                  style: AppTypography.titleSmall.copyWith(color: textColor),
                ),
                trailing: isSelected
                    ? const CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      )
                    : CircleAvatar(
                        radius: 12,
                        backgroundColor: isDark
                            ? AppColors.surfaceVariantDark
                            : AppColors.surfaceVariantLight,
                      ),
                onTap: () => setState(() {
                  if (isSelected) {
                    _selected.remove(c.id);
                  } else {
                    _selected.add(c.id);
                  }
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}
