import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jugaad_fix/models/jugaad_model.dart';
import 'package:jugaad_fix/screens/bookmarks_screen.dart';
import 'package:jugaad_fix/screens/home_screen.dart';
import 'package:jugaad_fix/screens/submit_screen.dart';
import 'package:jugaad_fix/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.init();
  final jugaads = await storage.loadAllJugaads();
  runApp(JugaadFixRoot(storage: storage, initialJugaads: jugaads));
}

/// Root widget holding shared state (jugaads, bookmarks, theme mode).
class JugaadFixRoot extends StatefulWidget {
  const JugaadFixRoot({
    super.key,
    required this.storage,
    required this.initialJugaads,
  });

  final StorageService storage;
  final List<Jugaad> initialJugaads;

  @override
  State<JugaadFixRoot> createState() => _JugaadFixRootState();
}

class _JugaadFixRootState extends State<JugaadFixRoot> {
  late List<Jugaad> _jugaads;
  int _currentIndex = 0;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _jugaads = widget.initialJugaads;
    final storedTheme = widget.storage.loadThemeMode();
    if (storedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (storedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jugaad Fix',
      themeMode: _themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton.extended(
                onPressed: () {
                  // Ensure we use the correct Navigator context.
                  _openSubmitScreen();
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Naya Jugaad'),
              )
            : null,
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: false,
      title: Text(
        'Jugaad Fix',
        style: GoogleFonts.balooBhai2(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Toggle Theme',
          icon: Icon(
            _themeMode == ThemeMode.dark
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
          ),
          onPressed: _toggleTheme,
        ),
      ],
    );
  }

  Widget _buildBody() {
    final bookmarked =
        _jugaads.where((j) => j.isBookmarked).toList(growable: false);
    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          allJugaads: _sortedByUpvotes(_jugaads),
          onToggleUpvote: _handleToggleUpvote,
          onToggleBookmark: _handleToggleBookmark,
          onOpenSubmit: _openSubmitScreen,
        );
      case 1:
        return BookmarksScreen(
          bookmarked: _sortedByUpvotes(bookmarked),
          onToggleBookmark: _handleToggleBookmark,
          onToggleUpvote: _handleToggleUpvote,
        );
      case 2:
        return _buildAbout();
      default:
        return const SizedBox.shrink();
    }
  }

  List<Jugaad> _sortedByUpvotes(List<Jugaad> list) {
    final copy = [...list];
    copy.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    return copy;
  }

  Widget _buildAbout() {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    // In dark mode, all body text should be white. In light mode, use theme colors.
    final bodyColor = isDark ? Colors.white : theme.textTheme.bodyMedium?.color;
    final bodyColorFaded = isDark
        ? Colors.white.withOpacity(0.85)
        : theme.textTheme.bodyMedium?.color?.withOpacity(0.8);
    final titleColor =
        isDark ? Colors.white : theme.textTheme.titleMedium?.color;

    return Container(
      // Use the same background as the rest of the app.
      color: theme.scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _AboutMandalaPainter(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withOpacity(0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'JF',
                            style: GoogleFonts.balooBhai2(
                              fontSize: 26,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jugaad Fix',
                            style: GoogleFonts.balooBhai2(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.9,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Roz ke problems, desi style ke solutions.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: bodyColorFaded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(
                Icons.offline_bolt_rounded,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Version 1.0.0',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: bodyColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Jugaad Fix ek community-sourced Indian life hacks ka adda hai — '
            'yahan power cut se leke monsoon tak, har situation ke liye kisi na kisi ne '
            'pehle hi ek solid jugaad nikaal rakha hai.',
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.4,
              color: bodyColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'App kya karta hai?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          _aboutPoint(
            'Smart feed of funny + useful Indian life hacks.',
          ),
          _aboutPoint(
            'Category wise browse – power cut, Internet, kitchen, travel, money, health, monsoon & more.',
          ),
          _aboutPoint(
            'Offline-first design – sab data aapke phone mein safe.',
          ),
          _aboutPoint(
            'Upvotes & bookmarks – apna favourite jugaad kabhi na bhoolo.',
          ),
          _aboutPoint(
            'Community submissions – apna hack bhejo, doosron ki life easy banao.',
          ),
          const SizedBox(height: 24),
          Text(
            'Made with ❤️ in India',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: bodyColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutPoint(String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bodyColor = isDark ? Colors.white : theme.textTheme.bodyMedium?.color;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  '),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: bodyColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() => _currentIndex = index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmark_outline_rounded),
          selectedIcon: Icon(Icons.bookmark_rounded),
          label: 'Bookmarks',
        ),
        NavigationDestination(
          icon: Icon(Icons.info_outline_rounded),
          selectedIcon: Icon(Icons.info_rounded),
          label: 'About',
        ),
      ],
    );
  }

  /// Reloads the list from storage after toggling so we don't rely on
  /// any initial sample list or out-of-scope variables.
  Future<void> _handleToggleUpvote(Jugaad target) async {
    await widget.storage.toggleUpvote(target.id);
    final updated = await widget.storage.loadAllJugaads();
    if (!mounted) return;
    setState(() {
      _jugaads = updated;
    });
  }

  Future<void> _handleToggleBookmark(Jugaad target) async {
    await widget.storage.toggleBookmark(target.id);
    final updated = await widget.storage.loadAllJugaads();
    if (!mounted) return;
    setState(() {
      _jugaads = updated;
    });
  }

  Future<void> _openSubmitScreen() async {
    final created = await Navigator.of(context).push<Jugaad>(
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
            child: const SubmitScreen(),
          ),
        ),
      ),
    );

    if (created != null) {
      await _handleAddJugaad(created);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shandaar! Jugaad community ke paas pahunch gaya 🎉'),
          ),
        );
      }
    }
  }

  Future<void> _handleAddJugaad(Jugaad jugaad) async {
    await widget.storage.addUserJugaad(jugaad);
    final updated = await widget.storage.loadAllJugaads();
    if (!mounted) return;
    setState(() {
      _jugaads = updated;
    });
  }

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
        widget.storage.saveThemeMode('dark');
      } else {
        _themeMode = ThemeMode.light;
        widget.storage.saveThemeMode('light');
      }
    });
  }
}

ThemeData _buildLightTheme() {
  const primary = Color(0xFFFF6B00); // Deep saffron
  const background = Color(0xFFFFF8F0); // Cream / off-white
  const textColor = Color(0xFF2C1810); // Dark brown

  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      background: background,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  return base.copyWith(
    scaffoldBackgroundColor: background,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: background,
      elevation: 0,
      centerTitle: false,
      foregroundColor: textColor,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      base.textTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
    ),
    cardColor: Colors.white,
    navigationBarTheme: base.navigationBarTheme.copyWith(
      indicatorColor: primary.withOpacity(0.18),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}

ThemeData _buildDarkTheme() {
  const primary = Color(0xFFFF6B00);
  const background = Color(0xFF110806); // Deep dark brown

  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      background: background,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  return base.copyWith(
    scaffoldBackgroundColor: background,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: background,
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
    cardColor: const Color(0xFF1C110D),
    navigationBarTheme: base.navigationBarTheme.copyWith(
      indicatorColor: primary.withOpacity(0.3),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}

/// Mandala-style decorative header used on the About tab.
class _AboutMandalaPainter extends CustomPainter {
  _AboutMandalaPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.2, size.height * 0.1);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 1.2;

    for (double radius = 40; radius < size.width; radius += 20) {
      canvas.drawCircle(center, radius, paint);
    }

    for (int i = 0; i < 16; i++) {
      final start = Offset(
        center.dx + 20 * (i.isEven ? 1 : -1) * 0.4,
        center.dy + 20 * (i.isEven ? 1 : -1) * 0.2,
      );
      final end = Offset(
        center.dx + (size.width * 0.7) * 0.6 * (i.isOdd ? 1 : -1),
        center.dy + (size.height * 0.7) * 0.2,
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}