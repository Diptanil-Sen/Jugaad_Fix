import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:share_plus/share_plus.dart';

import 'package:jugaad_fix/models/jugaad_model.dart';
import 'package:jugaad_fix/data/sample_data.dart';
import 'package:jugaad_fix/widgets/jugaad_card.dart';
import 'package:jugaad_fix/screens/detail_screen.dart';

typedef JugaadList = List<Jugaad>;

/// Simple keyword -> category mapping to make search feel smarter.
const Map<String, List<String>> _smartKeywordCategoryMap = {
  'car': ['travel'],
  'bike': ['travel'],
  'scooter': ['travel'],
  'auto': ['travel'],
  'cab': ['travel'],
  'ola': ['travel'],
  'uber': ['travel'],
  'parking': ['travel'],
  'traffic': ['travel'],
  'train': ['travel'],
  'bus': ['travel'],
  'railway': ['travel'],
  'airplane': ['travel'],
  'flight': ['travel'],
  'petrol': ['money', 'travel'],
  'diesel': ['money', 'travel'],
  'wifi': ['internet'],
  'internet': ['internet'],
  'network': ['internet'],
  'data': ['internet'],
  'router': ['internet'],
  'light': ['power'],
  'electricity': ['power'],
  'power cut': ['power'],
  'loadshedding': ['power'],
  'cooking': ['kitchen'],
  'gas': ['kitchen'],
  'stove': ['kitchen'],
  'chai': ['kitchen'],
  'health': ['health'],
  'doctor': ['health'],
  'medicine': ['health'],
  'gym': ['health'],
  'monsoon': ['monsoon'],
  'rain': ['monsoon'],
  'baarish': ['monsoon'],
  'paani': ['monsoon'],
  'money': ['money'],
  'budget': ['money'],
  'saving': ['money'],
  'savings': ['money'],
  'salary': ['money'],
};

/// Home screen with search, category chips, trending and main feed.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.allJugaads,
    required this.onToggleUpvote,
    required this.onToggleBookmark,
    required this.onOpenSubmit,
  });

  final JugaadList allJugaads;
  final void Function(Jugaad) onToggleUpvote;
  final void Function(Jugaad) onToggleBookmark;
  final Future<void> Function() onOpenSubmit;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedCategoryKey = JugaadCategories.allKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _applyFilters(widget.allJugaads);
    final trending = _topTrending(widget.allJugaads);
    // Compute related category suggestions when search is active.
    final relatedCategories =
        _relatedCategories(filtered, widget.allJugaads, _searchQuery);

    return Stack(
      children: [
        _MandalaBackground(theme: theme),
        Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Jugaad dhoondo... (power, kitchen, travel...)',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: theme.colorScheme.surface.withOpacity(0.9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.trim().toLowerCase());
                },
              ),
            ),
            _CategoryChips(
              selectedKey: _selectedCategoryKey,
              onSelected: (key) {
                setState(() => _selectedCategoryKey = key);
              },
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _TrendingStrip(
                      trending: trending,
                      onToggleBookmark: widget.onToggleBookmark,
                      onToggleUpvote: widget.onToggleUpvote,
                    ),
                  ),
                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptySearchState(
                        query: _searchQuery,
                        onOpenSubmit: widget.onOpenSubmit,
                      ),
                    )
                  else ...[
                    if (_searchQuery.isNotEmpty &&
                        filtered.length <= 3 &&
                        relatedCategories.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _RelatedCategorySuggestions(
                          categories: relatedCategories,
                          selectedKey: _selectedCategoryKey,
                          onSelected: (key) {
                            setState(() {
                              _selectedCategoryKey = key;
                            });
                          },
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 80),
                      sliver: AnimationLimiter(
                        child: SliverList.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return JugaadCard(
                              jugaad: item,
                              index: index,
                              onTap: () => _openDetail(item),
                              onToggleUpvote: () {
                                widget.onToggleUpvote(item);
                              },
                              onToggleBookmark: () {
                                widget.onToggleBookmark(item);
                              },
                              onShare: () {
                                _shareJugaad(item);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Jugaad> _applyFilters(List<Jugaad> all) {
    final query = _searchQuery.trim().toLowerCase();
    final tokens = query.isEmpty
        ? const <String>[]
        : query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    final mappedCategories = <String>{};
    for (final token in tokens) {
      final mapped = _smartKeywordCategoryMap[token];
      if (mapped != null) mappedCategories.addAll(mapped);
    }

    return all.where((j) {
      final matchesCategory = _selectedCategoryKey == JugaadCategories.allKey
          ? true
          : j.categoryKey == _selectedCategoryKey;
      if (!matchesCategory) return false;
      if (query.isEmpty) return true;
      final text = (j.title +
              j.description +
              j.shortDescription +
              (j.authorName ?? ''))
          .toLowerCase();
      final directMatch = text.contains(query) ||
          tokens.any(
            (token) => text.contains(token),
          );
      final semanticMatch = mappedCategories.contains(j.categoryKey);
      return directMatch || semanticMatch;
    }).toList()
      ..sort((a, b) => b.upvotes.compareTo(a.upvotes));
  }

  /// Suggest related categories for the current query.
  List<Map<String, String>> _relatedCategories(
    List<Jugaad> filtered,
    List<Jugaad> all,
    String rawQuery,
  ) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) return const [];

    final suggestionKeys = <String>{};
    final tokens = query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    for (final token in tokens) {
      final mapped = _smartKeywordCategoryMap[token];
      if (mapped != null) suggestionKeys.addAll(mapped);
    }

    // Also use categories from matching results so suggestions feel contextual.
    for (final j in filtered) {
      suggestionKeys.add(j.categoryKey);
    }

    // Avoid suggesting the category that's already selected.
    if (_selectedCategoryKey != JugaadCategories.allKey) {
      suggestionKeys.remove(_selectedCategoryKey);
    }

    return JugaadCategories.categories
        .where((c) => suggestionKeys.contains(c['key']))
        .cast<Map<String, String>>()
        .toList();
  }

  List<Jugaad> _topTrending(List<Jugaad> all) {
    final sorted = [...all]..sort(
        (a, b) => b.upvotes.compareTo(a.upvotes),
      );
    return sorted.take(3).toList();
  }

  void _openDetail(Jugaad jugaad) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
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

  void _shareJugaad(Jugaad jugaad) {
    final text = '${jugaad.title}\n\n${jugaad.description}\n\n'
        '— Jugaad Fix app se 👍';
    Share.share(text);
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.selectedKey,
    required this.onSelected,
  });

  final String selectedKey;
  final void Function(String key) onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      {'key': JugaadCategories.allKey, 'label': 'All', 'emoji': '✨'},
      ...JugaadCategories.categories,
    ];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = items[index];
          final key = item['key']!;
          final selected = key == selectedKey;
          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item['emoji'] ?? '', style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(item['label'] ?? '', style: const TextStyle(fontSize: 12)),
              ],
            ),
            selected: selected,
            onSelected: (_) => onSelected(key),
            labelStyle: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            selectedColor: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
            showCheckmark: false,
            side: BorderSide(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.dividerColor.withOpacity(0.3),
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: items.length,
      ),
    );
  }
}

class _TrendingStrip extends StatelessWidget {
  const _TrendingStrip({
    required this.trending,
    required this.onToggleBookmark,
    required this.onToggleUpvote,
  });

  final List<Jugaad> trending;
  final void Function(Jugaad) onToggleBookmark;
  final void Function(Jugaad) onToggleUpvote;

  @override
  Widget build(BuildContext context) {
    if (trending.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '🔥 Trending',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                'Top 3 jugaads',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 150,
          child: AnimationLimiter(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 8, bottom: 12),
              itemCount: trending.length,
              itemBuilder: (context, index) {
                final item = trending[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 450),
                  child: SlideAnimation(
                    horizontalOffset: 40,
                    child: FadeInAnimation(
                      child: _TrendingCard(
                        jugaad: item,
                        onToggleBookmark: () => onToggleBookmark(item),
                        onToggleUpvote: () => onToggleUpvote(item),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({
    required this.jugaad,
    required this.onToggleBookmark,
    required this.onToggleUpvote,
  });

  final Jugaad jugaad;
  final VoidCallback onToggleBookmark;
  final VoidCallback onToggleUpvote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.15),
            theme.colorScheme.primaryContainer.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      jugaad.categoryLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
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
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  onPressed: onToggleBookmark,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              jugaad.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.thumb_up_alt_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: onToggleUpvote,
                ),
                Text(
                  '${jugaad.upvotes}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state when search returns no results, nudging user to submit.
class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({
    required this.query,
    required this.onOpenSubmit,
  });

  final String query;
  final Future<void> Function() onOpenSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Koi jugaad nahi mila!',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Aap khud submit kar sakte ho 😊\n'
              'Ho sakta hai aapka hi hack kisi aur ki life easy bana de.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                onOpenSubmit();
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Apna Jugaad Submit Karo'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Suggests related categories as clickable chips when results are few.
class _RelatedCategorySuggestions extends StatelessWidget {
  const _RelatedCategorySuggestions({
    required this.categories,
    required this.selectedKey,
    required this.onSelected,
  });

  final List<Map<String, String>> categories;
  final String selectedKey;
  final void Function(String key) onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Related categories you can check:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: categories.map((c) {
              final key = c['key']!;
              final selected = key == selectedKey;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(c['emoji'] ?? ''),
                    const SizedBox(width: 6),
                    Text(c['label'] ?? ''),
                  ],
                ),
                selected: selected,
                onSelected: (_) => onSelected(key),
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                selectedColor: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
                showCheckmark: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MandalaBackground extends StatelessWidget {
  const _MandalaBackground({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.06),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: CustomPaint(
          painter: _MandalaPainter(
            color: theme.colorScheme.primary.withOpacity(0.05),
          ),
        ),
      ),
    );
  }
}

/// Simple radial pattern to give a subtle Indian mandala feel in the background.
class _MandalaPainter extends CustomPainter {
  _MandalaPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.8, -40);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 1.2;

    for (double radius = 60; radius < size.width * 1.2; radius += 26) {
      canvas.drawCircle(center, radius, paint);
    }

    for (int i = 0; i < 24; i++) {
      final angle = (i / 24) * 3.14159 * 2;
      final start = Offset(
        center.dx + 40 * (0.6 * i / 24) * (i.isEven ? 0.9 : -0.9),
        center.dy + 40 * (0.6 * i / 24),
      );
      final end = Offset(
        center.dx + (size.width * 0.9) * (0.6 * i / 24) * (i.isOdd ? 0.9 : -0.9),
        center.dy + (size.width * 0.9) * (0.6 * i / 24),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}