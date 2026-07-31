import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:share_plus/share_plus.dart';

import 'package:jugaad_fix/models/jugaad_model.dart';
import 'package:jugaad_fix/widgets/jugaad_card.dart';
import 'package:jugaad_fix/screens/detail_screen.dart';

/// Shows all bookmarked Jugaads.
class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({
    super.key,
    required this.bookmarked,
    required this.onToggleBookmark,
    required this.onToggleUpvote,
  });

  final List<Jugaad> bookmarked;
  final void Function(Jugaad) onToggleBookmark;
  final void Function(Jugaad) onToggleUpvote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (bookmarked.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark_outline_rounded,
                size: 64,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Abhi kuch save nahi kiya!',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Jo jugaad pasand aaye usko bookmark karo,\nphir yahan se araam se dekhna. Bilkul\napna personal jugaad collection.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: bookmarked.length,
        itemBuilder: (context, index) {
          final item = bookmarked[index];
          return JugaadCard(
            jugaad: item,
            index: index,
            onTap: () => _openDetail(context, item),
            onToggleUpvote: () => onToggleUpvote(item),
            onToggleBookmark: () => onToggleBookmark(item),
            onShare: () => _share(item),
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, Jugaad jugaad) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: DetailScreen(jugaad: jugaad),
          ),
        ),
      ),
    );
  }

  void _share(Jugaad jugaad) {
    final text = '${jugaad.title}\n\n${jugaad.description}\n\n'
        '— Jugaad Fix app se 👍';
    Share.share(text);
  }
}

