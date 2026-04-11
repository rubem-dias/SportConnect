import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/models/user_profile_model.dart';
import '../providers/profile_providers.dart';

void showEditProfileSheet(
  BuildContext context,
  UserProfileModel profile,
  String profileId,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => EditProfileSheet(
      profile: profile,
      profileId: profileId,
    ),
  );
}

class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({
    required this.profile, required this.profileId, super.key,
  });

  final UserProfileModel profile;
  final String profileId;

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  bool _isSaving = false;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _bioCtrl = TextEditingController(text: widget.profile.bio ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // fecha o bottom sheet de opções
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Câmera'),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Galeria'),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            if (widget.profile.avatar != null || _pickedImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error),
                title: const Text('Remover foto',
                    style: TextStyle(color: AppColors.error)),
                onTap: () {
                  setState(() => _pickedImage = null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      // In a real app, _pickedImage would be uploaded to storage and the URL passed here.
      // For mock purposes, we pass the local path as the avatar value.
      await ref.read(profileProvider(widget.profileId).notifier).updateProfile(
            name: name,
            bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
            avatar: _pickedImage?.path,
          );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Editar Perfil',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Avatar com troca de foto
                  Center(
                    child: GestureDetector(
                      onTap: _showImageSourceSheet,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.primary.withAlpha(40),
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!) as ImageProvider
                                : (widget.profile.avatar != null
                                    ? NetworkImage(widget.profile.avatar!)
                                    : null),
                            child: (_pickedImage == null &&
                                    widget.profile.avatar == null)
                                ? const Icon(Icons.person_rounded,
                                    size: 40, color: AppColors.primary)
                                : null,
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
                  AppTextField(
                    controller: _nameCtrl,
                    label: 'Nome',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _bioCtrl,
                    label: 'Bio',
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Salvar',
                    onPressed: _save,
                    isLoading: _isSaving,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
