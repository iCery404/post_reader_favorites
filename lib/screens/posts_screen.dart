import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/post.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cozy_widgets.dart';
import '../widgets/new_post_dialog.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  static const String routeName = '/';

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  static const String _postsUrl =
      'https://6acca690b406cb8ec0c62c6a.mockapi.io/api/v1/posts';

  List<Post> _posts = <Post>[];
  bool _loading = true;
  String? _error;

  String? _message;
  int _messageId = 0;
  MessageKind _messageKind = MessageKind.info;

  @override
  void initState() {
    super.initState();
    _loadPosts(); // async method called from initState()
  }

  // ---------------------------------------------------------------- GET
  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final Future<http.Response> request = http.get(Uri.parse(_postsUrl));
      final http.Response response =
          await request.timeout(const Duration(seconds: 15));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _posts = data
              .map((dynamic item) =>
                  Post.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Could not load posts (status code ${response.statusCode}).';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong while loading posts. '
            'Please check your internet connection and try again.\n($e)';
        _loading = false;
      });
    }
  }

  // --------------------------------------------------------------- POST
  Future<void> _openNewPostDialog() async {
    final NewPostData? data = await NewPostDialog.show(context);
    if (data == null || !mounted) return;

    try {
      final Future<http.Response> request = http.post(
        Uri.parse(_postsUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'title': data.title,
          'body': data.body,
          'userId': 1,
        }),
      );
      final http.Response response =
          await request.timeout(const Duration(seconds: 15));
      if (!mounted) return;

      if (response.statusCode == 201) {
        final Map<String, dynamic> created =
            Map<String, dynamic>.from(jsonDecode(response.body) as Map);
        _showMessage(
          'Post created successfully! (server assigned id ${created['id']})',
          MessageKind.success,
        );
      } else {
        _showMessage(
          'Failed to create post (status code ${response.statusCode}).',
          MessageKind.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage(
        'Failed to create post. Please check your connection.\n($e)',
        MessageKind.error,
      );
    }
  }

  void _showMessage(String message, MessageKind kind) {
    setState(() {
      _message = message;
      _messageKind = kind;
      _messageId++;
    });
  }

  // --------------------------------------------------------- Navigation
  void _openDetails(Post post) {
    Navigator.pushNamed(
      context,
      '/details',
      arguments: <String, dynamic>{
        'id': post.id,
        'title': post.title,
        'body': post.body,
      },
    );
  }

  void _openFavorites() {
    Navigator.pushNamed(context, '/favorites');
  }

  // -------------------------------------------------------------- Build
  @override
  Widget build(BuildContext context) {
    return CozyScaffold(
      title: 'Post Reader',
      actions: <Widget>[
        ValueListenableBuilder<Box<dynamic>>(
          valueListenable: FavoritesService.box.listenable(),
          builder: (BuildContext context, Box<dynamic> box, Widget? child) {
            return CozyIconButton(
              tooltip: 'Favorites',
              icon: Icons.favorite_rounded,
              badgeCount: box.length,
              onPressed: _openFavorites,
            );
          },
        ),
      ],
      floatingActionButton: CozyFab(
        onPressed: _openNewPostDialog,
        icon: Icons.add_rounded,
        label: 'New post',
      ),
      body: Column(
        children: <Widget>[
          AnimatedBanner(
            message: _message,
            messageId: _messageId,
            kind: _messageKind,
            onClose: () => setState(() => _message = null),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _posts.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: SectionTitle(
              icon: Icons.coffee_rounded,
              text: 'Brewing your posts...',
            ),
          ),
          Expanded(child: SkeletonList()),
        ],
      );
    }

    if (_error != null) {
      return CozyPlaceholder(
        icon: Icons.cloud_off_rounded,
        title: 'Oh no, no posts!',
        message: _error!,
        actionLabel: 'Try again',
        onAction: _loadPosts,
      );
    }

    if (_posts.isEmpty) {
      return const CozyPlaceholder(
        icon: Icons.menu_book_rounded,
        title: 'Nothing here yet',
        message: 'The server returned no posts.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: SectionTitle(
            icon: Icons.coffee_rounded,
            text: 'Latest posts',
            trailing: InfoPill(text: '${_posts.length} posts'),
          ),
        ),
        Expanded(child: _buildTable()),
      ],
    );
  }

  Widget _buildTable() {
    final TextStyle headerStyle = Theme.of(context)
        .textTheme
        .titleMedium!
        .copyWith(color: AppColors.ink);

    return Column(
      children: <Widget>[
        Container(height: 2, color: AppColors.outline),
        Container(
          width: double.infinity,
          color: AppColors.sage,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: <Widget>[
              SizedBox(width: 48, child: Text('#', style: headerStyle)),
              Text('Title', style: headerStyle),
            ],
          ),
        ),
        Container(height: 2, color: AppColors.outline),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.sageDark,
            onRefresh: _loadPosts,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: _posts.length,
              itemBuilder: (BuildContext context, int index) {
                final Post post = _posts[index];
                return FadeSlideIn(
                  index: index,
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      tileColor:
                          index.isEven ? AppColors.creamLight : AppColors.rowAlt,
                      hoverColor: AppColors.hover,
                      splashColor: AppColors.hover,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      minLeadingWidth: 36,
                      horizontalTitleGap: 12,
                      leading: IdBadge(id: post.id, size: 36),
                      title: Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        post.body.replaceAll('\n', ' '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.sageDark,
                      ),
                      onTap: () => _openDetails(post),
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
