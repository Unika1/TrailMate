import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/trek_model.dart';
import '../providers/trek_provider.dart';
import '../widgets/filter_pill.dart';
import '../widgets/trek_card.dart';
import 'trek_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(trekProvider).loadTreks());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(trekProvider);
    final treks = provider.filteredTreks;

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
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic)),
            SizedBox(width: 4),
            Icon(Icons.hiking, color: AppColors.dark, size: 22),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search + filters (fixed header)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (q) =>
                      ref.read(trekProvider).updateSearchQuery(q),
                  decoration: InputDecoration(
                    hintText: 'Search treks, peaks, or regions',
                    hintStyle: const TextStyle(
                        color: AppColors.mutedText, fontSize: 14),
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.textGrey),
                    filled: true,
                    fillColor: AppColors.fieldFill,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilterPill(
                      value: provider.selectedRegion,
                      items: const [
                        'All Treks',
                        'Everest Region',
                        'Annapurna Region',
                        'Langtang Region'
                      ],
                      onChanged: (v) => provider.updateFilters(region: v),
                    ),
                    const SizedBox(width: 8),
                    FilterPill(
                      value: provider.selectedDuration,
                      items: const [
                        'Duration',
                        '2-3 Days',
                        '7-10 Days',
                        '12+ Days'
                      ],
                      onChanged: (v) => provider.updateFilters(duration: v),
                    ),
                    const SizedBox(width: 8),
                    FilterPill(
                      value: provider.selectedDifficulty,
                      items: const [
                        'Difficulty',
                        'Easy',
                        'Moderate',
                        'Difficult'
                      ],
                      onChanged: (v) => provider.updateFilters(difficulty: v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Trek list
          Expanded(child: _buildList(provider, treks)),
        ],
      ),
    );
  }

  Widget _buildList(TrekProvider provider, List<TrekModel> treks) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 52, color: AppColors.textGrey),
              const SizedBox(height: 12),
              Text(provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textGrey)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: Colors.white),
                onPressed: () => ref.read(trekProvider).loadTreks(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (treks.isEmpty) {
      return const Center(
        child: Text('No treks found.',
            style: TextStyle(color: AppColors.textGrey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: treks.length,
      itemBuilder: (_, i) => TrekCard(
        trek: treks[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TrekDetailScreen(trek: treks[i])),
        ),
      ),
    );
  }
}
