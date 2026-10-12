import 'package:hive/hive.dart';

import '../models/post.dart';

/// A favorite post as stored in Hive (a Map) plus the user's personal note.
class FavoritePost {
  const FavoritePost({
    required this.id,
    required this.title,
    required this.body,
    this.note = '',
  });

  final int id;
  final String title;
  final String body;
  final String note;

  factory FavoritePost.fromMap(Map<dynamic, dynamic> map) {
    return FavoritePost(
      id: (map['id'] as num).toInt(),
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      note: (map['note'] as String?) ?? '',
    );
  }
}

/// All Hive CRUD for favorites lives here.
///
/// Each post is stored as a Map in the box, using the post id as the key,
/// so the same post can never be saved twice.
class FavoritesService {
  FavoritesService._();

  static const String boxName = 'favoritesBox';

  static Box<dynamic> get box => Hive.box<dynamic>(boxName);

  /// CREATE - returns false when the post was already saved.
  static Future<bool> add(Post post) async {
    if (box.containsKey(post.id)) return false;
    await box.put(post.id, <String, dynamic>{
      'id': post.id,
      'title': post.title,
      'body': post.body,
      'note': '',
    });
    return true;
  }

  static bool isFavorite(int id) => box.containsKey(id);

  /// READ - every saved post, using box.values.
  static List<FavoritePost> readAll() {
    return box.values
        .map((dynamic v) => FavoritePost.fromMap(Map<dynamic, dynamic>.from(v)))
        .toList()
      ..sort((FavoritePost a, FavoritePost b) => a.id.compareTo(b.id));
  }

  /// UPDATE - save a personal note back to the same key.
  static Future<void> updateNote(int id, String note) async {
    final dynamic current = box.get(id);
    if (current == null) return;
    final Map<String, dynamic> updated = <String, dynamic>{
      ...Map<String, dynamic>.from(current as Map),
      'note': note,
    };
    await box.put(id, updated);
  }

  /// DELETE - remove a saved post.
  static Future<void> remove(int id) => box.delete(id);
}
