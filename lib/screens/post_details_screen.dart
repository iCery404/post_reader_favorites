import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/post.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cozy_widgets.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({super.key});

  static const String routeName = '/details';

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  String? _message;
  int _messageId = 0;
  MessageKind _messageKind = MessageKind.info;

  Future<void> _saveToFavorites(Post post) async {
    final bool added = await FavoritesService.add(post);
    if (!mounted) return;
    setState(() {
      if (added) {
        _message = 'Saved to your favorites!';
        _messageKind = MessageKind.success;
      } else {
        _message = 'This post is already in your favorites.';
        _messageKind = MessageKind.info;
      }
      _messageId++;
    });
  }

  Widget _buildPostCard(Post post) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.caramel, width: 2),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: AppColors.caramelDark, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IdBadge(id: post.id, size: 48),
              const SizedBox(width: 12),
              Expanded(child: Text(post.title, style: text.titleLarge)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.caramel, thickness: 2, height: 2),
          const SizedBox(height: 14),
          Text(post.body, style: text.bodyLarge),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Map<String, dynamic>.from(
      ModalRoute.of(context)!.settings.arguments! as Map,
    );
    final Post post = Post(
      id: args['id'] as int,
      title: args['title'] as String,
      body: args['body'] as String,
    );

    return CozyScaffold(
      title: 'Post Details',
      body: Column(
        children: <Widget>[
          AnimatedBanner(
            message: _message,
            messageId: _messageId,
            kind: _messageKind,
            onClose: () => setState(() => _message = null),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: <Widget>[
                FadeSlideIn(child: _buildPostCard(post)),
                const SizedBox(height: 28),
                FadeSlideIn(
                  index: 1,
                  child: ValueListenableBuilder<Box<dynamic>>(
                    valueListenable: FavoritesService.box.listenable(),
                    builder:
                        (BuildContext context, Box<dynamic> box, Widget? _) {
                      final bool saved = box.containsKey(post.id);
                      return CozyButton(
                        label: saved ? 'Saved to Favorites' : 'Save to Favorites',
                        icon: saved
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        expand: true,
                        onPressed: () => _saveToFavorites(post),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                FadeSlideIn(
                  index: 2,
                  child: CozyButton(
                    label: 'View my favorites',
                    icon: Icons.collections_bookmark_rounded,
                    style: CozyButtonStyle.sage,
                    expand: true,
                    onPressed: () => Navigator.pushNamed(context, '/favorites'),
                  ),
                ),
                const SizedBox(height: 14),
                FadeSlideIn(
                  index: 3,
                  child: CozyButton(
                    label: 'Back to posts',
                    icon: Icons.arrow_back_rounded,
                    style: CozyButtonStyle.cream,
                    expand: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
