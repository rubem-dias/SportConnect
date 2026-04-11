import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum AppAvatarSize { xs, sm, md, lg, xl }

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppAvatarSize.md,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.onTap,
  });

  final String? imageUrl;
  final String? name;
  final AppAvatarSize size;
  final bool showOnlineIndicator;
  final bool isOnline;
  final VoidCallback? onTap;

  double get _diameter => switch (size) {
        AppAvatarSize.xs => 24,
        AppAvatarSize.sm => 36,
        AppAvatarSize.md => 48,
        AppAvatarSize.lg => 64,
        AppAvatarSize.xl => 96,
      };

  double get _indicatorSize => _diameter * 0.25;

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final Widget avatar = GestureDetector(
      onTap: onTap,
      child: Container(
        width: _diameter,
        height: _diameter,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        clipBehavior: Clip.antiAlias,
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _Placeholder(initials: _initials, diameter: _diameter),
                errorWidget: (_, __, ___) =>
                    _Placeholder(initials: _initials, diameter: _diameter),
              )
            : _Placeholder(initials: _initials, diameter: _diameter),
      ),
    );

    if (!showOnlineIndicator) return avatar;

    return Stack(
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: _indicatorSize,
            height: _indicatorSize,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.online : AppColors.offline,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.initials, required this.diameter});

  final String initials;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: diameter * 0.36,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

