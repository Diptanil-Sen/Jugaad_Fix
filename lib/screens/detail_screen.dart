import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:jugaad_fix/models/jugaad_model.dart';

/// Standalone detail view for a single Jugaad.
class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.jugaad,
    this.onToggleBookmark,
    this.onToggleUpvote,
  });

  final Jugaad jugaad;
  final VoidCallback? onToggleBookmark;
  final VoidCallback? onToggleUpvote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authorLine =
        jugaad.authorName == null ? '' : 'By ${jugaad.authorName}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jugaad Details'),
        actions: [
          IconButton(
            icon: Icon(
              jugaad.isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
            ),
            onPressed: onToggleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  jugaad.categoryEmoji,
                  style: const TextStyle(fontSize: 26),
                ),
                const SizedBox(width: 8),
                Text(
                  jugaad.categoryLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              jugaad.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (authorLine.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                authorLine,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Text(
                jugaad.description,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      onToggleUpvote?.call();
                      final snackBar = SnackBar(
                        content: Text(
                          'Jhakaas! Upvote registered for "${jugaad.title}"',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    icon: const Icon(Icons.thumb_up_alt_rounded),
                    label: Text('Upvote (${jugaad.upvotes})'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareJugaad(jugaad),
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Share Jugaad'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareJugaad(Jugaad jugaad) {
    final text = '${jugaad.title}\n\n${jugaad.description}\n\n'
        '— Jugaad Fix app se 👍';
    Share.share(text);
  }
}

