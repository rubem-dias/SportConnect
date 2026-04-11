import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/story_model.dart';
import '../providers/story_provider.dart';

class StoriesBar extends ConsumerWidget {
  const StoriesBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(storiesProvider);

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        itemCount: groups.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final group = groups[index];
          return _StoryAvatar(
            group: group,
            onTap: () {
              if (group.isMe && group.stories.isEmpty) {
                // ignore: open story creation — not yet implemented
                return;
              }
              Navigator.of(context).push(
                PageRouteBuilder<void>(
                  opaque: false,
                  barrierColor: Colors.black,
                  pageBuilder: (_, __, ___) => StoryViewer(
                    groups: groups
                        .where((g) => !g.isMe || g.stories.isNotEmpty)
                        .toList(),
                    initialGroupIndex: group.isMe ? 0 : index - 1,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  const _StoryAvatar({required this.group, required this.onTap});

  final StoryGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasUnviewed = group.hasUnviewed;
    final isMe = group.isMe;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Gradient ring for unviewed / dashed for me
                if (isMe && group.stories.isEmpty)
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withAlpha(80),
                        width: 2,
                      ),
                    ),
                  )
                else if (hasUnviewed)
                  Container(
                    width: 62,
                    height: 62,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary,
                          AppColors.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.textDisabledLight,
                        width: 2,
                      ),
                    ),
                  ),

                // Avatar
                CircleAvatar(
                  radius: 27,
                  backgroundImage: group.userAvatar != null
                      ? NetworkImage(group.userAvatar!)
                      : null,
                  backgroundColor: AppColors.surfaceVariantLight,
                  child: group.userAvatar == null
                      ? const Icon(Icons.person_rounded)
                      : null,
                ),

                // Add icon for my story
                if (isMe && group.stories.isEmpty)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isMe ? 'Seu story' : group.userName,
              style: AppTypography.labelSmall.copyWith(
                color: hasUnviewed || (isMe && group.stories.isEmpty)
                    ? AppColors.primary
                    : AppColors.textSecondaryLight,
                fontWeight:
                    hasUnviewed ? FontWeight.w600 : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Story Viewer (Fullscreen) ─────────────────────────────────────────────────

class StoryViewer extends ConsumerStatefulWidget {
  const StoryViewer({
    required this.groups,
    required this.initialGroupIndex,
    super.key,
  });

  final List<StoryGroup> groups;
  final int initialGroupIndex;

  @override
  ConsumerState<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends ConsumerState<StoryViewer>
    with SingleTickerProviderStateMixin {
  late int _groupIndex;
  late int _storyIndex;
  late AnimationController _progressController;

  static const _storyDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _groupIndex = widget.initialGroupIndex.clamp(0, widget.groups.length - 1);
    _storyIndex = 0;
    _progressController = AnimationController(vsync: this, duration: _storyDuration)
      ..addStatusListener(_onAnimationStatus)
      ..forward();
    _markCurrentViewed();
  }

  @override
  void dispose() {
    _progressController
      ..removeStatusListener(_onAnimationStatus)
      ..dispose();
    super.dispose();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _nextStory();
    }
  }

  StoryGroup get _currentGroup => widget.groups[_groupIndex];
  StoryModel get _currentStory => _currentGroup.stories[_storyIndex];

  void _markCurrentViewed() {
    ref.read(storiesProvider.notifier).markViewed(
          _currentGroup.userId,
          _currentStory.id,
        );
  }

  void _nextStory() {
    if (_storyIndex < _currentGroup.stories.length - 1) {
      setState(() => _storyIndex++);
      _restart();
      _markCurrentViewed();
    } else if (_groupIndex < widget.groups.length - 1) {
      setState(() {
        _groupIndex++;
        _storyIndex = 0;
      });
      _restart();
      _markCurrentViewed();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prevStory() {
    if (_storyIndex > 0) {
      setState(() => _storyIndex--);
      _restart();
    } else if (_groupIndex > 0) {
      setState(() {
        _groupIndex--;
        _storyIndex = widget.groups[_groupIndex].stories.length - 1;
      });
      _restart();
    }
  }

  void _restart() {
    _progressController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final story = _currentStory;
    final group = _currentGroup;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final x = details.globalPosition.dx;
          final width = MediaQuery.of(context).size.width;
          if (x < width / 3) {
            _progressController.stop();
          } else if (x > (2 * width / 3)) {
            _progressController.stop();
          }
        },
        onTapUp: (details) {
          final x = details.globalPosition.dx;
          final width = MediaQuery.of(context).size.width;
          if (x < width / 3) {
            _prevStory();
          } else {
            _nextStory();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Media
            Image.network(
              story.mediaUrl,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
            ),

            // Gradient overlay top
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),

            // Gradient overlay bottom
            if (story.text != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                ),
              ),

            // Progress bars
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              child: Row(
                children: List.generate(
                  group.stories.length,
                  (i) => Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 2),
                      child: _ProgressBar(
                        progress: i < _storyIndex
                            ? 1.0
                            : i == _storyIndex
                                ? _progressController
                                : 0.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Header
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: group.userAvatar != null
                        ? NetworkImage(group.userAvatar!)
                        : null,
                    backgroundColor: Colors.white24,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.userName,
                          style: AppTypography.titleSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _timeAgo(story.createdAt),
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Text overlay
            if (story.text != null)
              Positioned(
                bottom: 60,
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                child: Text(
                  story.text!,
                  style: AppTypography.headlineSmall.copyWith(
                    color: Color(story.textColor ?? 0xFFFFFFFF),
                    shadows: [
                      const Shadow(
                        blurRadius: 8,
                        color: Colors.black54,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    return 'há ${diff.inHours}h';
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final dynamic progress; // double or Animation<double>

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 3,
        child: progress is Animation<double>
            ? AnimatedBuilder(
                animation: progress as Animation<double>,
                builder: (_, __) => LinearProgressIndicator(
                  value: (progress as Animation<double>).value,
                  backgroundColor: Colors.white38,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : LinearProgressIndicator(
                value: (progress as double).toDouble(),
                backgroundColor: Colors.white38,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
      ),
    );
  }
}
