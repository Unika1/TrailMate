import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/show_message.dart';
import '../../data/models/trek_model.dart';
import '../providers/trek_provider.dart';
import 'comments_screen.dart';

class TrekDetailScreen extends ConsumerWidget {
  final TrekModel trek;
  const TrekDetailScreen({super.key, required this.trek});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(trekProvider).isRouteSaved(trek.id);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.dark,
              surfaceTintColor: Colors.white,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.35)),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              actions: [
                IconButton(
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.35)),
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white),
                  onPressed: () async {
                    await ref.read(trekProvider).saveRoute(trek);
                    if (context.mounted) {
                      showMessage(
                          context,
                          isSaved
                              ? 'Route removed from saved'
                              : 'Route saved successfully');
                    }
                  },
                ),
                IconButton(
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.35)),
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () =>
                      showMessage(context, 'Route shared successfully'),
                ),
                const SizedBox(width: 6),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _Hero(trek: trek),
              ),
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: ColoredBox(
                  color: Colors.white,
                  child: TabBar(
                    labelColor: AppColors.brand,
                    unselectedLabelColor: AppColors.textGrey,
                    indicatorColor: AppColors.brand,
                    indicatorWeight: 2.5,
                    labelStyle:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    tabs: [
                      Tab(text: 'OVERVIEW'),
                      Tab(text: 'ITINERARY'),
                      Tab(text: 'COST'),
                      Tab(text: 'CONTACTS'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _OverviewTab(trek: trek),
              _ItineraryTab(trek: trek),
              _CostTab(trek: trek),
              _ContactsTab(trek: trek),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero ─────────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  final TrekModel trek;
  const _Hero({required this.trek});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        trek.imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: ApiConstants.imageUrl(trek.imageUrl),
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.primarySoft),
                errorWidget: (_, __, ___) => Container(
                    color: AppColors.primarySoft,
                    child: const Icon(Icons.terrain,
                        size: 64, color: AppColors.primary)),
              )
            : Container(
                color: AppColors.primarySoft,
                child: const Icon(Icons.terrain,
                    size: 64, color: AppColors.primary)),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
              begin: Alignment.center,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(trek.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 8)])),
              const SizedBox(height: 6),
              Row(
                children: [
                  _HeroBadge(
                      icon: Icons.terrain,
                      text: trek.maxAltitude.replaceAll(',', '')),
                  const SizedBox(width: 8),
                  _HeroBadge(icon: Icons.schedule, text: trek.duration),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HeroBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(text.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Shared section header (icon + title) ─────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.brand),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final TrekModel trek;
  const _OverviewTab({required this.trek});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Text(trek.overview,
            style: const TextStyle(
                fontSize: 14, height: 1.6, color: AppColors.textGrey)),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.0,
          children: [
            _InfoTile(
                icon: Icons.schedule, label: 'DURATION', value: trek.duration),
            _InfoTile(
                icon: Icons.straighten,
                label: 'DISTANCE',
                value: trek.distance),
            _InfoTile(
                icon: Icons.terrain, label: 'MAX ALT', value: trek.maxAltitude),
            _InfoTile(
                icon: Icons.trending_up,
                label: 'DIFFICULTY',
                value: trek.difficulty),
          ],
        ),
        const _SectionHeader(icon: Icons.ac_unit, title: 'Best Season'),
        if (trek.seasons.isNotEmpty)
          ...trek.seasons.map((s) => _SeasonCard(season: s))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: trek.bestSeason
                .map((s) => Chip(
                    label: Text(s),
                    backgroundColor: AppColors.primarySoft))
                .toList(),
          ),
        const SizedBox(height: 14),
        if (trek.lastUpdated.isNotEmpty)
          _UpdateRow(
              icon: Icons.schedule,
              text: 'Route information last updated: ${trek.lastUpdated}'),
        if (trek.contactsVerified.isNotEmpty)
          _UpdateRow(
              icon: Icons.verified_outlined,
              text: 'Emergency contacts verified: ${trek.contactsVerified}'),
        const _SectionHeader(icon: Icons.landscape, title: 'Trek Highlights'),
        ...trek.highlights.map(
          (h) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                      color: AppColors.primarySoft, shape: BoxShape.circle),
                  child: const Icon(Icons.check,
                      size: 14, color: AppColors.brand),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(h, style: const TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (trek.nearbyTreks.isNotEmpty) ...[
          const _SectionHeader(
              icon: Icons.explore_outlined, title: 'Nearby Treks'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: trek.nearbyTreks
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(t,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: 20),
        _CommentsButton(trekId: trek.id, trekName: trek.name),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.brand, size: 18),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _SeasonCard extends StatelessWidget {
  final TrekSeason season;
  const _SeasonCard({required this.season});

  @override
  Widget build(BuildContext context) {
    final isSpring = season.name.toLowerCase().contains('spring');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: AppColors.primarySoft, shape: BoxShape.circle),
            child: Icon(isSpring ? Icons.local_florist : Icons.eco,
                color: AppColors.brand, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(season.name.toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
                Text(season.months,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                Text(season.description,
                    style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12.5,
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _UpdateRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.brand),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.textGrey, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }
}

class _CommentsButton extends StatelessWidget {
  final String trekId;
  final String trekName;
  const _CommentsButton({required this.trekId, required this.trekName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  CommentsScreen(trekId: trekId, trekName: trekName))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.comment_outlined, color: AppColors.brand),
            SizedBox(width: 12),
            Expanded(
              child: Text('Read & add trekker comments',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}

// ── Itinerary Tab ────────────────────────────────────────────────────────────

class _ItineraryTab extends StatelessWidget {
  final TrekModel trek;
  const _ItineraryTab({required this.trek});

  @override
  Widget build(BuildContext context) {
    if (trek.itinerary.isEmpty) {
      return const Center(
        child: Text('Itinerary details coming soon.',
            style: TextStyle(color: AppColors.textGrey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      itemCount: trek.itinerary.length,
      itemBuilder: (context, index) {
        final day = trek.itinerary[index];
        final isLast = index == trek.itinerary.length - 1;
        final isRest = day.status.isNotEmpty;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                          color: AppColors.brand, shape: BoxShape.circle),
                      child: Center(
                        child: Text('${day.day}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13)),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: AppColors.primarySoft),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(day.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 14)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.fieldFill,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                                'Day ${day.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textGrey)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _MiniLabel(label: 'ALTITUDE', value: day.altitude),
                          const SizedBox(width: 28),
                          _MiniLabel(
                              label: isRest ? 'STATUS' : 'DURATION',
                              value: isRest ? day.status : day.walkingHours),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(day.description,
                          style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.5,
                              color: AppColors.textGrey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniLabel extends StatelessWidget {
  final String label;
  final String value;
  const _MiniLabel({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 9,
                color: AppColors.mutedText,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        const SizedBox(height: 1),
        Text(value,
            style:
                const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ── Cost Tab ─────────────────────────────────────────────────────────────────

class _CostTab extends StatelessWidget {
  final TrekModel trek;
  const _CostTab({required this.trek});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        if (trek.costNotice.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    size: 18, color: Color(0xFF3B82F6)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Important Notice',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFF1E3A8A))),
                      const SizedBox(height: 3),
                      Text(trek.costNotice,
                          style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.5,
                              color: Color(0xFF1E40AF))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        const Text('Estimated Budget',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (trek.budget.isNotEmpty)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: trek.budget.map((b) => _BudgetCard(item: b)).toList(),
          ),
        const SizedBox(height: 20),
        const Text('Permit Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ...trek.permits.map((p) => _PermitCard(permit: p)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.brand, AppColors.primary]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Estimate',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              Text(trek.cost.totalEstimate,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final BudgetItem item;
  const _BudgetCard({required this.item});

  IconData get _icon {
    switch (item.icon) {
      case 'permit':
        return Icons.assignment_outlined;
      case 'transport':
        return Icons.flight_outlined;
      case 'hotel':
        return Icons.hotel_outlined;
      case 'food':
        return Icons.restaurant_outlined;
      default:
        return Icons.payments_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                    color: AppColors.primarySoft, shape: BoxShape.circle),
                child: Icon(_icon, size: 18, color: AppColors.brand),
              ),
              Text(item.note,
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedText,
                      letterSpacing: 0.5)),
            ],
          ),
          const Spacer(),
          Text(item.label,
              style:
                  const TextStyle(fontSize: 12.5, color: AppColors.textGrey)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('NPR ',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey)),
              Text(item.amount,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brand)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PermitCard extends StatelessWidget {
  final PermitInfo permit;
  const _PermitCard({required this.permit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(permit.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
              ),
              Text(permit.fee,
                  style: const TextStyle(
                      color: AppColors.brand,
                      fontWeight: FontWeight.w800,
                      fontSize: 14)),
            ],
          ),
          if (permit.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(permit.description,
                style: const TextStyle(
                    fontSize: 12.5, height: 1.5, color: AppColors.textGrey)),
          ],
          if (permit.whereToGet.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.brand),
                const SizedBox(width: 5),
                Expanded(
                  child: Text('Obtain: ${permit.whereToGet}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.brand,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Contacts Tab ─────────────────────────────────────────────────────────────

class _ContactsTab extends StatelessWidget {
  final TrekModel trek;
  const _ContactsTab({required this.trek});

  @override
  Widget build(BuildContext context) {
    final jeep = trek.contacts.where((c) => c.type == 'jeep').toList();
    final hotels = trek.contacts.where((c) => c.type == 'hotel').toList();
    final emergency =
        trek.contacts.where((c) => c.type == 'emergency').toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.fieldFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                boxShadow: const [
                  BoxShadow(color: Color(0x14000000), blurRadius: 4),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppColors.dark,
              unselectedLabelColor: AppColors.textGrey,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              tabs: const [
                Tab(text: 'JEEP'),
                Tab(text: 'HOTELS'),
                Tab(text: 'EMERGENCY'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _JeepList(contacts: jeep),
                _HotelList(contacts: hotels),
                _EmergencyList(
                    contacts: emergency, coordinates: trek.coordinates),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JeepList extends StatelessWidget {
  final List<TrekContact> contacts;
  const _JeepList({required this.contacts});

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) return const _EmptyContacts();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: contacts.length,
      itemBuilder: (_, i) {
        final c = contacts[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: AppColors.fieldFill,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.directions_car_filled_outlined,
                    color: AppColors.brand),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('Est. Fare: ${c.price}',
                        style: const TextStyle(
                            color: AppColors.textGrey, fontSize: 12.5)),
                  ],
                ),
              ),
              Text(c.phone,
                  style: const TextStyle(
                      color: AppColors.brand,
                      fontWeight: FontWeight.w800,
                      fontSize: 14)),
            ],
          ),
        );
      },
    );
  }
}

class _HotelList extends StatelessWidget {
  final List<TrekContact> contacts;
  const _HotelList({required this.contacts});

  static IconData amenityIcon(String a) {
    final k = a.toLowerCase();
    if (k.contains('wifi')) return Icons.wifi;
    if (k.contains('hot')) return Icons.water_drop_outlined;
    if (k.contains('charge')) return Icons.power_outlined;
    if (k.contains('heat')) return Icons.local_fire_department_outlined;
    if (k.contains('food')) return Icons.restaurant_outlined;
    return Icons.check_circle_outline;
  }

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) return const _EmptyContacts();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: contacts.length,
      itemBuilder: (_, i) {
        final c = contacts[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: c.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: ApiConstants.imageUrl(c.imageUrl),
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: AppColors.primarySoft),
                            errorWidget: (_, __, ___) => Container(
                                color: AppColors.primarySoft,
                                child: const Icon(Icons.hotel,
                                    color: AppColors.primary)),
                          )
                        : Container(
                            color: AppColors.primarySoft,
                            child: const Icon(Icons.hotel,
                                color: AppColors.primary)),
                  ),
                  if (c.badge.isNotEmpty)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.brand,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(c.badge,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5)),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 13, color: AppColors.textGrey),
                                  const SizedBox(width: 3),
                                  Text(c.location,
                                      style: const TextStyle(
                                          color: AppColors.textGrey,
                                          fontSize: 12.5)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(c.phone,
                                  style: const TextStyle(
                                      color: AppColors.brand,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('NPR ${c.price}',
                                style: const TextStyle(
                                    color: AppColors.brand,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                            const Text('PER NIGHT',
                                style: TextStyle(
                                    color: AppColors.mutedText,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                    if (c.amenities.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: c.amenities
                            .map((a) => Expanded(
                                  child: Column(
                                    children: [
                                      Icon(amenityIcon(a),
                                          size: 18,
                                          color: AppColors.textGrey),
                                      const SizedBox(height: 4),
                                      Text(a.toUpperCase(),
                                          style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textGrey)),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmergencyList extends StatelessWidget {
  final List<TrekContact> contacts;
  final TrekCoordinates? coordinates;
  const _EmergencyList({required this.contacts, required this.coordinates});

  bool _isPolice(String name) => name.toLowerCase().contains('police');

  @override
  Widget build(BuildContext context) {
    final simple = contacts.where((c) => c.description.isEmpty).toList();
    final detailed = contacts.where((c) => c.description.isNotEmpty).toList();

    if (contacts.isEmpty && (coordinates == null || coordinates!.isEmpty)) {
      return const _EmptyContacts();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        ...simple.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                        color: _isPolice(c.name)
                            ? const Color(0xFFE0E7FF)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                        _isPolice(c.name)
                            ? Icons.local_police_outlined
                            : Icons.emergency_outlined,
                        color: _isPolice(c.name)
                            ? const Color(0xFF4F46E5)
                            : AppColors.danger),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(c.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                  Text(c.phone,
                      style: const TextStyle(
                          color: AppColors.brand,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                ],
              ),
            )),
        if (detailed.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Air & High Altitude Support',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mutedText,
                    letterSpacing: 0.5)),
          ),
          ...detailed.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                              color: AppColors.fieldFill,
                              borderRadius: BorderRadius.circular(10)),
                          child: Icon(
                              c.badge.contains('AIR')
                                  ? Icons.flight_outlined
                                  : Icons.terrain,
                              size: 20,
                              color: AppColors.brand),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(c.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 14)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E7FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(c.badge,
                              style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4F46E5))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(c.description,
                        style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: AppColors.textGrey)),
                    const SizedBox(height: 6),
                    Text(c.phone,
                        style: const TextStyle(
                            color: AppColors.brand,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                  ],
                ),
              )),
        ],
        if (coordinates != null && !coordinates!.isEmpty)
          _CoordinatesCard(coordinates: coordinates!),
      ],
    );
  }
}

class _CoordinatesCard extends StatelessWidget {
  final TrekCoordinates coordinates;
  const _CoordinatesCard({required this.coordinates});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Last Known Coordinates',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const Icon(Icons.my_location, color: AppColors.brand, size: 18),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LATITUDE',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(coordinates.latitude,
                        style: const TextStyle(
                            color: AppColors.brand,
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LONGITUDE',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(coordinates.longitude,
                        style: const TextStyle(
                            color: AppColors.brand,
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Elevation: ${coordinates.elevation}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12)),
              GestureDetector(
                onTap: () => showMessage(context, 'Sharing live location...'),
                child: const Row(
                  children: [
                    Icon(Icons.share, color: AppColors.brand, size: 14),
                    SizedBox(width: 4),
                    Text('SHARE LIVE',
                        style: TextStyle(
                            color: AppColors.brand,
                            fontWeight: FontWeight.w700,
                            fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyContacts extends StatelessWidget {
  const _EmptyContacts();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No contacts available for this category.',
          style: TextStyle(color: AppColors.textGrey)),
    );
  }
}
