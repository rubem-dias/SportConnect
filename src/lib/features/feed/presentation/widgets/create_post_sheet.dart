import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../prs/data/models/pr_model.dart';
import '../../../prs/presentation/providers/prs_provider.dart';
import '../../data/repositories/feed_repository_impl.dart';
import '../providers/feed_provider.dart';

// Rascunho salvo em memória (poderia ser Hive em produção)
final _draftProvider = StateProvider<String>((ref) => '');

enum _Privacy { everyone, followers, community }

void showCreatePostSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CreatePostSheet(),
  );
}

class _CreatePostSheet extends ConsumerStatefulWidget {
  const _CreatePostSheet();

  @override
  ConsumerState<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<_CreatePostSheet> {
  late final TextEditingController _textCtrl;
  final _focusNode = FocusNode();

  _Privacy _privacy = _Privacy.everyone;
  ExercisePRSummary? _sharedPR;
  final List<String> _selectedMediaPaths = [];
  bool _isPosting = false;
  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    // Restore draft
    final draft = ref.read(_draftProvider);
    _textCtrl = TextEditingController(text: draft);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // Save draft on close
    ref.read(_draftProvider.notifier).state = _textCtrl.text;
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canPost =>
      _textCtrl.text.trim().isNotEmpty || _selectedMediaPaths.isNotEmpty;

  Future<void> _post() async {
    if (!_canPost) return;
    setState(() {
      _isPosting = true;
      _uploadProgress = 0;
    });

    try {
      // Simulate upload progress
      for (var i = 1; i <= 10; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 60));
        if (!mounted) return;
        setState(() => _uploadProgress = i / 10);
      }

      await ref.read(feedRepositoryProvider).createPost(
            content: _textCtrl.text.trim(),
            mediaUrls: _selectedMediaPaths,
            prId: _sharedPR?.bestPR.id,
            privacy: _privacy.name,
          );

      // Clear draft
      ref.read(_draftProvider.notifier).state = '';

      // Refresh feed
      ref.read(feedProvider.notifier).refresh();

      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, context.l10n.createPostSuccess);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPosting = false);
        AppSnackbar.error(context, context.l10n.createPostError);
      }
    }
  }

  void _selectPR() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PRPickerSheet(
        onSelect: (summary) {
          setState(() => _sharedPR = summary);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.sm, 0),
              child: Row(
                children: [
                  Text(context.l10n.createPostTitle, style: AppTypography.titleMedium),
                  const Spacer(),
                  _PrivacyButton(
                    value: _privacy,
                    onChanged: (p) => setState(() => _privacy = p),
                  ),
                  TextButton(
                    onPressed: _canPost && !_isPosting ? _post : null,
                    child: _isPosting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.l10n.createPostPublish),
                  ),
                ],
              ),
            ),

            // Upload progress bar
            if (_isPosting)
              LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: AppColors.borderLight,
                color: AppColors.primary,
                minHeight: 2,
              ),

            // Text field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: TextField(
                controller: _textCtrl,
                focusNode: _focusNode,
                maxLines: null,
                minLines: 4,
                maxLength: 2000,
                onChanged: (_) => setState(() {}),
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: context.l10n.createPostHint,
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  border: InputBorder.none,
                  counterText: '',
                ),
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                    null,
              ),
            ),

            // Selected PR preview
            if (_sharedPR != null)
              _PRPreviewBanner(
                summary: _sharedPR!,
                onRemove: () => setState(() => _sharedPR = null),
              ),

            // Media thumbnails
            if (_selectedMediaPaths.isNotEmpty)
              _MediaPreviewRow(
                paths: _selectedMediaPaths,
                onRemove: (i) =>
                    setState(() => _selectedMediaPaths.removeAt(i)),
              ),

            const Divider(height: 1),

            // Action bar
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    _ActionIconBtn(
                      icon: Icons.photo_library_outlined,
                      label: context.l10n.createPostGallery,
                      onTap: () => _pickMedia(fromCamera: false),
                    ),
                    _ActionIconBtn(
                      icon: Icons.camera_alt_outlined,
                      label: context.l10n.createPostCamera,
                      onTap: () => _pickMedia(fromCamera: true),
                    ),
                    _ActionIconBtn(
                      icon: Icons.emoji_events_outlined,
                      label: context.l10n.createPostPR,
                      onTap: _selectPR,
                    ),
                    _ActionIconBtn(
                      icon: Icons.tag_rounded,
                      label: context.l10n.createPostHashtag,
                      onTap: () => _insertText('#'),
                    ),
                    _ActionIconBtn(
                      icon: Icons.alternate_email_rounded,
                      label: context.l10n.createPostMention,
                      onTap: () => _insertText('@'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickMedia({required bool fromCamera}) {
    // In production, use image_picker package.
    // For now, add a placeholder URL to simulate selection.
    setState(() {
      _selectedMediaPaths.add(
        'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400/300',
      );
    });
  }

  void _insertText(String text) {
    final sel = _textCtrl.selection;
    final before = _textCtrl.text.substring(0, sel.start.clamp(0, _textCtrl.text.length));
    final after = _textCtrl.text.substring(sel.end.clamp(0, _textCtrl.text.length));
    _textCtrl.value = TextEditingValue(
      text: '$before$text$after',
      selection: TextSelection.collapsed(offset: before.length + text.length),
    );
    _focusNode.requestFocus();
  }
}

class _PrivacyButton extends StatelessWidget {
  const _PrivacyButton({required this.value, required this.onChanged});

  final _Privacy value;
  final void Function(_Privacy) onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_Privacy>(
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: _Privacy.everyone,
          child: Row(children: [
            const Icon(Icons.public_rounded, size: 18),
            const SizedBox(width: 8),
            Text(ctx.l10n.createPostPrivacyEveryone),
          ]),
        ),
        PopupMenuItem(
          value: _Privacy.followers,
          child: Row(children: [
            const Icon(Icons.people_rounded, size: 18),
            const SizedBox(width: 8),
            Text(ctx.l10n.createPostPrivacyFollowers),
          ]),
        ),
        PopupMenuItem(
          value: _Privacy.community,
          child: Row(children: [
            const Icon(Icons.groups_rounded, size: 18),
            const SizedBox(width: 8),
            Text(ctx.l10n.createPostPrivacyCommunity),
          ]),
        ),
      ],
      child: Chip(
        avatar: Icon(_privacyIcon(value), size: 14, color: AppColors.primary),
        label: Text(_privacyLabel(context, value),
            style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
        backgroundColor: AppColors.primary.withOpacity(0.1),
        side: BorderSide.none,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  IconData _privacyIcon(_Privacy p) => switch (p) {
        _Privacy.everyone => Icons.public_rounded,
        _Privacy.followers => Icons.people_rounded,
        _Privacy.community => Icons.groups_rounded,
      };

  String _privacyLabel(BuildContext context, _Privacy p) => switch (p) {
        _Privacy.everyone => context.l10n.createPostPrivacyEveryone,
        _Privacy.followers => context.l10n.createPostPrivacyFollowers,
        _Privacy.community => context.l10n.createPostPrivacyCommunity,
      };
}

class _ActionIconBtn extends StatelessWidget {
  const _ActionIconBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: IconButton(
        icon: Icon(icon, size: 22),
        color: AppColors.textSecondaryLight,
        onPressed: onTap,
        splashRadius: 20,
      ),
    );
  }
}

class _PRPreviewBanner extends StatelessWidget {
  const _PRPreviewBanner({required this.summary, required this.onRemove});

  final ExercisePRSummary summary;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.prGreen.withOpacity(0.15),
            AppColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.prGreen.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary.exerciseName,
                    style: AppTypography.labelMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(summary.bestPR.displayValue,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.prGreen,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _MediaPreviewRow extends StatelessWidget {
  const _MediaPreviewRow({required this.paths, required this.onRemove});

  final List<String> paths;
  final void Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
        itemCount: paths.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) => Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.network(
                paths[i],
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  color: AppColors.surfaceVariantLight,
                  child: const Icon(Icons.image_outlined, size: 24),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => onRemove(i),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- PR Picker Sheet ----

class _PRPickerSheet extends ConsumerWidget {
  const _PRPickerSheet({required this.onSelect});
  final void Function(ExercisePRSummary) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prsAsync = ref.watch(prsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(context.l10n.createPostSelectPR,
                  style: AppTypography.titleMedium),
            ),
            Expanded(
              child: prsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    Center(child: Text(context.l10n.prsEmptyTitle)),
                data: (data) => data.summaries.isEmpty
                    ? Center(
                        child: Text(context.l10n.createPostNoPRs))
                    : ListView.builder(
                        controller: ctrl,
                        itemCount: data.summaries.length,
                        itemBuilder: (_, i) {
                          final s = data.summaries[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.prGreen.withOpacity(0.15),
                              child: const Text('🏆'),
                            ),
                            title: Text(s.exerciseName),
                            subtitle: Text(s.bestPR.displayValue),
                            onTap: () {
                              Navigator.pop(context);
                              onSelect(s);
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
