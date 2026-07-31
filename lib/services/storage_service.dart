import 'package:shared_preferences/shared_preferences.dart';

import 'package:jugaad_fix/models/jugaad_model.dart';
import 'package:jugaad_fix/data/sample_data.dart';

/// Keys used inside SharedPreferences.
class _PrefsKeys {
  static const upvotedIds = 'upvoted_ids';
  static const bookmarkedIds = 'bookmarked_ids';
  static const userJugaads = 'user_jugaads';
  static const themeMode = 'theme_mode'; // 'light' | 'dark' | 'system'
}

/// Encapsulates all local persistence so the rest of the app stays clean.
class StorageService {
  StorageService._(this._prefs);

  final SharedPreferences _prefs;

  /// Factory that must be awaited at app startup.
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  /// Loads base sample data and merges stored state (votes, bookmarks, user items).
  Future<List<Jugaad>> loadAllJugaads() async {
    final upvoted =
        _prefs.getStringList(_PrefsKeys.upvotedIds) ?? <String>[];
    final bookmarked =
        _prefs.getStringList(_PrefsKeys.bookmarkedIds) ?? <String>[];
    final userJson = _prefs.getString(_PrefsKeys.userJugaads);

    final List<Jugaad> userCreated = userJson == null || userJson.isEmpty
        ? <Jugaad>[]
        : Jugaad.decodeList(userJson)
            .map((j) => j.copyWithState(
                  upvotes: upvoted.contains(j.id) ? (j.upvotes + 1) : j.upvotes,
                  isBookmarked: bookmarked.contains(j.id),
                ))
            .toList();

    final List<Jugaad> base = initialJugaads
        .map(
          (j) => j.copyWithState(
            upvotes: upvoted.contains(j.id) ? (j.upvotes + 1) : j.upvotes,
            isBookmarked: bookmarked.contains(j.id),
          ),
        )
        .toList();

    return [...base, ...userCreated];
  }

  Future<void> toggleUpvote(String id) async {
    final existing =
        _prefs.getStringList(_PrefsKeys.upvotedIds) ?? <String>[];
    if (existing.contains(id)) {
      existing.remove(id);
    } else {
      existing.add(id);
    }
    await _prefs.setStringList(_PrefsKeys.upvotedIds, existing);
  }

  Future<void> toggleBookmark(String id) async {
    final existing =
        _prefs.getStringList(_PrefsKeys.bookmarkedIds) ?? <String>[];
    if (existing.contains(id)) {
      existing.remove(id);
    } else {
      existing.add(id);
    }
    await _prefs.setStringList(_PrefsKeys.bookmarkedIds, existing);
  }

  Future<void> addUserJugaad(Jugaad jugaad) async {
    final existingJson = _prefs.getString(_PrefsKeys.userJugaads);
    final List<Jugaad> list = existingJson == null || existingJson.isEmpty
        ? <Jugaad>[]
        : Jugaad.decodeList(existingJson);
    list.add(jugaad);
    await _prefs.setString(_PrefsKeys.userJugaads, Jugaad.encodeList(list));
  }

  String? loadThemeMode() => _prefs.getString(_PrefsKeys.themeMode);

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_PrefsKeys.themeMode, mode);
  }
}

