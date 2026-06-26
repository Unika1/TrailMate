import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/show_message.dart';
import '../providers/auth_provider.dart';
import '../providers/trek_provider.dart';

/// "Share Your Journey" — full-screen add-comment form (experience + photo).
/// Photo upload is a visual placeholder (not persisted); the text is saved to
/// the backend via TrekProvider.addComment.
class ShareJourneyScreen extends ConsumerStatefulWidget {
  final String trekId;
  const ShareJourneyScreen({super.key, required this.trekId});

  @override
  ConsumerState<ShareJourneyScreen> createState() =>
      _ShareJourneyScreenState();
}

class _ShareJourneyScreenState extends ConsumerState<ShareJourneyScreen> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  bool _submitting = false;
  File? _photo;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _photo = File(picked.path));
      }
    } catch (_) {
      if (mounted) showMessage(context, 'Could not open gallery');
    }
  }

  Future<void> _submit() async {
    final message = _controller.text.trim();
    if (message.isEmpty) {
      showMessage(context, 'Please describe your experience first');
      return;
    }
    final userName = ref.read(authProvider).userName;

    setState(() => _submitting = true);
    try {
      await ref.read(trekProvider).addComment(
            widget.trekId,
            userName,
            message,
            imagePath: _photo?.path,
          );
      if (mounted) {
        Navigator.pop(context, true);
        showMessage(context, 'Added Comment successfully!');
      }
    } catch (_) {
      if (mounted) showMessage(context, 'Failed to submit. Please try again.');
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const SizedBox(height: 8),
          const Center(
            child: Text('Share Your Journey',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Your reports help the community stay safe and inspired.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: 13.5),
            ),
          ),
          const SizedBox(height: 28),
          const _Label('Your Experience'),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Describe the trail conditions, weather, and highlights...',
              hintStyle:
                  const TextStyle(color: AppColors.mutedText, fontSize: 13.5),
              filled: true,
              fillColor: AppColors.fieldFill,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 22),
          const _Label('Visual Evidence'),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload photo
              Expanded(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.fieldFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined,
                            color: AppColors.textGrey),
                        SizedBox(height: 6),
                        Text('Upload Photo',
                            style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
              if (_photo != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _photo!,
                          height: 96,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => setState(() => _photo = null),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: AppColors.brand,
                                shape: BoxShape.circle),
                            padding: const EdgeInsets.all(3),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send, size: 18),
              label: Text(_submitting ? 'Submitting...' : 'Submit Comment',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textGrey,
            letterSpacing: 0.5));
  }
}
