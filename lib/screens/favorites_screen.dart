import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/favorites_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cozy_widgets.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  static const String routeName = '/favorites';

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String? _message;
  int _messageId = 0;
  MessageKind _messageKind = MessageKind.info;

  final Set<int> _removing = <int>{};
  final Set<int> _collapsing = <int>{};

  void _showMessage(String message, MessageKind kind) {
    setState(() {
      _message = message;
      _messageKind = kind;
      _messageId++;
    });
  }

  Future<void> _editNote(FavoritePost favorite) async {
    final String? note = await showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          _NoteDialog(initialNote: favorite.note),
    );
    if (note == null || !mounted) return;

    await FavoritesService.updateNote(favorite.id, note);
    if (!mounted) return;
    _showMessage(
      note.isEmpty ? 'Note cleared.' : 'Note saved!',
      MessageKind.success,
    );
  }

  Future<void> _delete(FavoritePost favorite) async {
    setState(() => _removing.add(favorite.id));
    await FavoritesService.remove(favorite.id);
    if (!mounted) return;
    setState(() => _removing.remove(favorite.id));
    _showMessage(
      'Removed "${favorite.title}" from favorites.',
      MessageKind.info,
    );
  }

  Future<void> _deleteWithAnimation(FavoritePost favorite) async {
    if (_collapsing.contains(favorite.id)) return;
    setState(() => _collapsing.add(favorite.id));
    await Future.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;
    await _delete(favorite);
    if (!mounted) return;
    setState(() => _collapsing.remove(favorite.id));
  }

  @override
  Widget build(BuildContext context) {
    return CozyScaffold(
      title: 'My Favorites',
      body: Column(
        children: <Widget>[
          AnimatedBanner(
            message: _message,
            messageId: _messageId,
            kind: _messageKind,
            onClose: () => setState(() => _message = null),
          ),
          Expanded(
            child: ValueListenableBuilder<Box<dynamic>>(
              valueListenable: FavoritesService.box.listenable(),
              builder: (BuildContext context, Box<dynamic> box, Widget? _) {
                final List<FavoritePost> favorites = FavoritesService.readAll()
                    .where((FavoritePost f) => !_removing.contains(f.id))
                    .toList();

                if (favorites.isEmpty) {
                  return const CozyPlaceholder(
                    icon: Icons.favorite_border_rounded,
                    title: 'No favorites yet',
                    message:
                        'Open a post and tap "Save to Favorites" to keep it here.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: favorites.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            child: SectionTitle(
                              icon: Icons.coffee_rounded,
                              text: 'Saved posts',
                              trailing:
                                  InfoPill(text: '${favorites.length} saved'),
                            ),
                          ),
                          Container(height: 2, color: AppColors.outline),
                        ],
                      );
                    }
                    final FavoritePost fav = favorites[index - 1];
                    return FadeSlideIn(
                      key: ValueKey<int>(fav.id),
                      index: index - 1,
                      child: _FavoriteTile(
                        favorite: fav,
                        color: index.isOdd
                            ? AppColors.creamLight
                            : AppColors.rowAlt,
                        collapsing: _collapsing.contains(fav.id),
                        onEdit: () => _editNote(fav),
                        onSwipeDelete: () => _delete(fav),
                        onBinDelete: () => _deleteWithAnimation(fav),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({
    required this.favorite,
    required this.color,
    required this.collapsing,
    required this.onEdit,
    required this.onSwipeDelete,
    required this.onBinDelete,
  });

  final FavoritePost favorite;
  final Color color;
  final bool collapsing;
  final VoidCallback onEdit;
  final VoidCallback onSwipeDelete;
  final VoidCallback onBinDelete;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1, end: collapsing ? 0 : 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (BuildContext context, double value, Widget? child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: value,
            child: Opacity(opacity: value, child: child),
          ),
        );
      },
      child: Dismissible(
        key: ValueKey<int>(favorite.id),
        background: const _SwipeBackground(alignment: Alignment.centerLeft),
        secondaryBackground:
            const _SwipeBackground(alignment: Alignment.centerRight),
        onDismissed: (DismissDirection _) => onSwipeDelete(),
        child: Material(
          color: color,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.caramel, width: 1.5),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                IdBadge(id: favorite.id),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(favorite.title, style: text.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        favorite.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium,
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        alignment: Alignment.topCenter,
                        child: favorite.note.isEmpty
                            ? const SizedBox(width: double.infinity, height: 0)
                            : Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.creamLight,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.caramel,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const Icon(
                                        Icons.sticky_note_2_rounded,
                                        size: 18,
                                        color: AppColors.caramelDark,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          favorite.note,
                                          style: text.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    CozyIconButton(
                      tooltip: 'Edit note',
                      icon: Icons.edit_rounded,
                      color: AppColors.sageDark,
                      onPressed: onEdit,
                    ),
                    CozyIconButton(
                      tooltip: 'Delete',
                      icon: Icons.delete_rounded,
                      color: AppColors.danger,
                      onPressed: onBinDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.blush,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.delete_rounded, color: Colors.white, size: 28),
          SizedBox(width: 8),
          Text(
            'Remove',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.initialNote});

  final String initialNote;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialNote);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CozyDialogFrame(
      title: 'Personal Note',
      actions: <Widget>[
        CozyButton(
          label: 'Cancel',
          style: CozyButtonStyle.cream,
          onPressed: () => Navigator.of(context).pop(),
        ),
        CozyButton(
          label: 'Save',
          icon: Icons.check_rounded,
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
        ),
      ],
      child: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 2,
        maxLines: 4,
        maxLength: 140,
        decoration: const InputDecoration(
          labelText: 'Write a short note',
          hintText: 'Why do you like this post?',
        ),
      ),
    );
  }
}
