import 'dart:convert';

/// Represents a single Jugaad (clever life hack).
class Jugaad {
  final String id;
  final String title;
  final String categoryKey;
  final String categoryEmoji;
  final String categoryLabel;
  final String shortDescription;
  final String description;
  final String? authorName;
  final bool isUserCreated;

  /// Local-only dynamic state
  int upvotes;
  bool isBookmarked;

  Jugaad({
    required this.id,
    required this.title,
    required this.categoryKey,
    required this.categoryEmoji,
    required this.categoryLabel,
    required this.shortDescription,
    required this.description,
    this.authorName,
    this.isUserCreated = false,
    this.upvotes = 0,
    this.isBookmarked = false,
  });

  /// Creates a copy with updated voting / bookmark flags.
  Jugaad copyWithState({
    int? upvotes,
    bool? isBookmarked,
  }) {
    return Jugaad(
      id: id,
      title: title,
      categoryKey: categoryKey,
      categoryEmoji: categoryEmoji,
      categoryLabel: categoryLabel,
      shortDescription: shortDescription,
      description: description,
      authorName: authorName,
      isUserCreated: isUserCreated,
      upvotes: upvotes ?? this.upvotes,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'categoryKey': categoryKey,
      'categoryEmoji': categoryEmoji,
      'categoryLabel': categoryLabel,
      'shortDescription': shortDescription,
      'description': description,
      'authorName': authorName,
      'isUserCreated': isUserCreated,
      'upvotes': upvotes,
      'isBookmarked': isBookmarked,
    };
  }

  factory Jugaad.fromJson(Map<String, dynamic> json) {
    return Jugaad(
      id: json['id'] as String,
      title: json['title'] as String,
      categoryKey: json['categoryKey'] as String,
      categoryEmoji: json['categoryEmoji'] as String,
      categoryLabel: json['categoryLabel'] as String,
      shortDescription: json['shortDescription'] as String,
      description: json['description'] as String,
      authorName: json['authorName'] as String?,
      isUserCreated: json['isUserCreated'] as bool? ?? false,
      upvotes: json['upvotes'] as int? ?? 0,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }

  static String encodeList(List<Jugaad> list) =>
      jsonEncode(list.map((j) => j.toJson()).toList());

  static List<Jugaad> decodeList(String source) {
    final List<dynamic> decoded = jsonDecode(source) as List<dynamic>;
    return decoded
        .map((item) => Jugaad.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

