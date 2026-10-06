import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/cast_member.dart';
import 'custom_network_image.dart';

/// Card displaying cast member avatar, actor name, and character name.
class CastCard extends StatelessWidget {
  final CastMember cast;

  const CastCard({
    Key? key,
    required this.cast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary.withOpacity(0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: cast.profilePath != null && cast.profilePath!.isNotEmpty
                  ? CustomNetworkImage(
                      imageUrl: cast.profilePath!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppTheme.surfaceLight,
                      child: const Icon(Icons.person, color: AppTheme.textMuted, size: 36),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cast.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            cast.character,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
