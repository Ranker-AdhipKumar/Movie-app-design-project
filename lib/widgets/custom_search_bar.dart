import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Styled search bar widget for filtering movies.
class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final bool readOnly;
  final String hintText;
  final bool autofocus;

  const CustomSearchBar({
    Key? key,
    this.controller,
    this.onChanged,
    this.onClear,
    this.onTap,
    this.readOnly = false,
    this.hintText = 'Search movies, genres, actors...',
    this.autofocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF222638), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        autofocus: autofocus,
        onTap: onTap,
        onChanged: onChanged,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        cursorColor: AppTheme.primary,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 22),
          suffixIcon: controller != null && controller!.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted, size: 20),
                  onPressed: () {
                    controller!.clear();
                    if (onClear != null) onClear!();
                    if (onChanged != null) onChanged!('');
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
