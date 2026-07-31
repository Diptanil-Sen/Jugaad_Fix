import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:jugaad_fix/models/jugaad_model.dart';

/// Reusable card used across the home and bookmarks screens.
class JugaadCard extends StatelessWidget {
  const JugaadCard({
    super.key,
    required this.jugaad,
    required this.index,
    required this.onTap,
    required this.onToggleUpvote,
    required this.onToggleBookmark,
    required this.onShare,
  });

  final Jugaad jugaad;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onToggleUpvote;
  final VoidCallback onToggleBookmark;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 450),
      child: SlideAnimation(
        verticalOffset: 40,
        curve: Curves.easeOutCubic,
        child: FadeInAnimation(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              jugaad.categoryEmoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              jugaad.categoryLabel,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            jugaad.isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_outline_rounded,
                            color: jugaad.isBookmarked
                                ? theme.colorScheme.primary
                                : theme.iconTheme.color?.withOpacity(0.7),
                          ),
                          onPressed: onToggleBookmark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      jugaad.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      jugaad.shortDescription,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: onToggleUpvote,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.thumb_up_alt_rounded,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${jugaad.upvotes}',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (jugaad.isUserCreated)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer
                                      .withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  'Community',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.share_rounded,
                            color: theme.iconTheme.color?.withOpacity(0.8),
                          ),
                          onPressed: onShare,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

