import 'package:flutter_test/flutter_test.dart';
import 'package:post_reader_favorites/models/post.dart';

void main() {
  test('Post.fromJson parses a JSONPlaceholder post', () {
    final Post post = Post.fromJson(<String, dynamic>{
      'userId': 1,
      'id': 7,
      'title': 'hello',
      'body': 'world',
    });

    expect(post.id, 7);
    expect(post.title, 'hello');
    expect(post.body, 'world');
    expect(post.toJson()['id'], 7);
  });
}
