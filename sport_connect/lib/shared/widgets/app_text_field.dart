import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.label,
    super.key,
    this.controller,
    this.focusNode,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.autocorrect = true,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool autocorrect;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      autocorrect: widget.autocorrect,
      textCapitalization: widget.textCapitalization,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textSecondaryLight,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : widget.suffixIcon,
      ),
    );
  }
}
