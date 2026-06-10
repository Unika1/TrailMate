import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/show_message.dart';
import '../../data/models/trek_model.dart';
import '../providers/trek_provider.dart';

/// Large photo trek card matching the Figma Home / Explore design:
/// full-width image, altitude badge, name + bookmark, region, days + difficulty.
class TrekCard extends ConsumerWidget {
  final TrekModel trek;
  final VoidCallback onTap;

  const TrekCard({super.key, required this.trek, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(trekProvider).isRouteSaved(trek.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with altitude badge
            Stack(
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: trek.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: trek.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: AppColors.primarySoft),
                          errorWidget: (_, __, ___) => _imgFallback(),
                        )
                      : _imgFallback(),
                ),
                if (trek.maxAltitude.isNotEmpty)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        trek.maxAltitude.replaceAll(',', ''),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          trek.name,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await ref.read(trekProvider).saveRoute(trek);
                          if (context.mounted) {
                            showActionMessage(
                              context,
                              isSaved
                                  ? 'Route removed from saved'
                                  : 'Route saved successfully',
                              actionLabel: 'UNDO',
                              onAction: () =>
                                  ref.read(trekProvider).saveRoute(trek),
                            );
                          }
                        },
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved
                              ? AppColors.brand
                              : AppColors.textGrey,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textGrey),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          trek.region,
                          style: const TextStyle(
                              color: AppColors.textGrey, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule,
                            size: 15, color: AppColors.brand),
                        const SizedBox(width: 5),
                        Text(
                          trek.duration.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark),
                        ),
                        const SizedBox(width: 18),
                        Icon(Icons.terrain,
                            size: 15, color: _difficultyColor(trek.difficulty)),
                        const SizedBox(width: 5),
                        Text(
                          trek.difficulty,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _difficultyColor(trek.difficulty)),
                        ),
                      ],
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

  Widget _imgFallback() => Container(
        color: AppColors.primarySoft,
        alignment: Alignment.center,
        child: const Icon(Icons.terrain, color: AppColors.primary, size: 40),
      );

  Color _difficultyColor(String d) {
    switch (d.toLowerCase()) {
      case 'easy':
        return AppColors.accent;
      case 'difficult':
        return AppColors.danger;
      default:
        return AppColors.textGrey; // Moderate
    }
  }
}
