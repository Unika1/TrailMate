import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/trek_provider.dart';
import '../widgets/filter_pill.dart';
import '../widgets/trek_card.dart';
import 'trek_detail_screen.dart';

class TrekListScreen extends ConsumerStatefulWidget {
  const TrekListScreen({super.key});

  @override
  ConsumerState<TrekListScreen> createState() => _TrekListScreenState();
}

class _TrekListScreenState extends ConsumerState<TrekListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(trekProvider);
    final treks = provider.filteredTreks;
    final hasActiveFilter = provider.selectedRegion != 'All Treks' ||
        provider.selectedDuration != 'Duration' ||
        provider.selectedDifficulty != 'Difficulty' ||
        _searchController.text.isNotEmpty;

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
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (q) => ref.read(trekProvider).updateSearchQuery(q),
                  decoration: InputDecoration(
                    hintText: 'Search treks, peaks, or regions',
                    hintStyle: const TextStyle(
                        color: AppColors.mutedText, fontSize: 14),
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.textGrey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppColors.textGrey),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(trekProvider).updateSearchQuery('');
                            },
                          )
                        : null,
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
          // Result count + reset
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${treks.length} trek${treks.length == 1 ? '' : 's'} found',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                        fontSize: 13)),
                if (hasActiveFilter)
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.brand,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    onPressed: () {
                      _searchController.clear();
                      provider.resetFilters();
                    },
                    child: const Text('Reset all',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : treks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off,
                                  size: 48, color: AppColors.textGrey),
                              SizedBox(height: 12),
                              Text('No treks match your filters.',
                                  style:
                                      TextStyle(color: AppColors.textGrey)),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: treks.length,
                        itemBuilder: (_, i) => TrekCard(
                          trek: treks[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    TrekDetailScreen(trek: treks[i])),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
