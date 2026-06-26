import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/trek_provider.dart';
import 'share_journey_screen.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String trekId;
  final String trekName;

  const CommentsScreen({
    super.key,
    required this.trekId,
    this.trekName = '',
  });

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(trekProvider).loadComments(widget.trekId));
  }

  Future<void> _openShare() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ShareJourneyScreen(trekId: widget.trekId)),
    );
    if (mounted) ref.read(trekProvider).loadComments(widget.trekId);
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(trekProvider).comments;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        onPressed: _openShare,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('ADD COMMENT',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        children: [
          const Text('Trip Comments',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
            'Real insights from fellow trekkers. Find the latest trail conditions, summit advice, and gear advice.',
            style:
                TextStyle(color: AppColors.textGrey, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          if (comments.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 48, color: AppColors.textGrey),
                  SizedBox(height: 12),
                  Text('No comments yet.',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('Be the first to share your experience!',
                      style: TextStyle(color: AppColors.textGrey)),
                ],
              ),
            )
          else
            ...comments.map((c) => _CommentCard(
                  userName: c.userName,
                  message: c.message,
                  date: c.date,
                  imageUrl: c.imageUrl,
                  trekName: widget.trekName,
                )),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final String userName;
  final String message;
  final String date;
  final String imageUrl;
  final String trekName;

  const _CommentCard({
    required this.userName,
    required this.message,
    required this.date,
    required this.imageUrl,
    required this.trekName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(userName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                    overflow: TextOverflow.ellipsis),
              ),
              Text(_timeAgo(date),
                  style: const TextStyle(
                      color: AppColors.mutedText, fontSize: 11)),
            ],
          ),
          if (trekName.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(trekName,
                style: const TextStyle(
                    color: AppColors.brand,
                    fontWeight: FontWeight.w800,
                    fontSize: 15)),
          ],
          const SizedBox(height: 6),
          Text(message,
              style: const TextStyle(
                  fontSize: 13, height: 1.5, color: AppColors.textGrey)),
          if (imageUrl.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                    height: 180, color: AppColors.fieldFill),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _timeAgo(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}
