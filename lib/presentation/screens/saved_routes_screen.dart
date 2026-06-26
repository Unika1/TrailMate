import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/show_message.dart';
import '../../data/models/trek_model.dart';
import '../providers/trek_provider.dart';
import 'trek_detail_screen.dart';

class SavedRoutesScreen extends ConsumerStatefulWidget {
  const SavedRoutesScreen({super.key});

  @override
  ConsumerState<SavedRoutesScreen> createState() => _SavedRoutesScreenState();
}

class _SavedRoutesScreenState extends ConsumerState<SavedRoutesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(trekProvider).loadSavedRoutes());
  }

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(trekProvider).savedRoutes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: const Row(
          children: [
            Text('TrailMate',
                style: TextStyle(
                    color: AppColors.brand,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic)),
            SizedBox(width: 4),
            Icon(Icons.hiking, color: AppColors.dark, size: 20),
          ],
        ),
      ),
      body: saved.isEmpty
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const Text('Saved Routes',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text(
                  'Manage your personalized collection of future expeditions.',
                  style: TextStyle(
                      color: AppColors.textGrey, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 18),
                ...saved.map((trek) => _SavedCard(trek: trek)),
              ],
            ),
    );
  }
}

class _SavedCard extends ConsumerWidget {
  final TrekModel trek;
  const _SavedCard({required this.trek});

  Color _difficultyColor(String d) {
    switch (d.toLowerCase()) {
      case 'easy':
        return AppColors.accent;
      case 'difficult':
        return AppColors.danger;
      default:
        return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: trek.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: trek.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppColors.primarySoft),
                        errorWidget: (_, __, ___) => Container(
                            color: AppColors.primarySoft,
                            child: const Icon(Icons.terrain,
                                color: AppColors.primary)),
                      )
                    : Container(
                        color: AppColors.primarySoft,
                        child: const Icon(Icons.terrain,
                            color: AppColors.primary)),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () async {
                    await ref.read(trekProvider).saveRoute(trek); // removes it
                    if (context.mounted) {
                      showActionMessage(
                        context,
                        'Route removed from saved',
                        actionLabel: 'UNDO',
                        onAction: () =>
                            ref.read(trekProvider).saveRoute(trek),
                      );
                    }
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    padding: const EdgeInsets.all(7),
                    child: const Icon(Icons.bookmark,
                        color: AppColors.brand, size: 18),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trek.name,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.textGrey),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(trek.region,
                          style: const TextStyle(
                              color: AppColors.textGrey, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 14, color: AppColors.brand),
                    const SizedBox(width: 4),
                    Text(trek.duration,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 16),
                    const Icon(Icons.terrain, size: 14, color: AppColors.brand),
                    const SizedBox(width: 4),
                    Text(trek.maxAltitude.replaceAll(',', ''),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 16),
                    Icon(Icons.trending_up,
                        size: 14, color: _difficultyColor(trek.difficulty)),
                    const SizedBox(width: 4),
                    Text(trek.difficulty,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _difficultyColor(trek.difficulty))),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TrekDetailScreen(trek: trek)),
                    ),
                    child: const Text('VIEW ROUTE',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 0.5)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: AppColors.textGrey),
            SizedBox(height: 16),
            Text('No saved routes yet.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text(
              'Open a trek and tap the bookmark icon\nto save it for offline planning.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
