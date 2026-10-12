class Post {
  const Post({
    required this.id,
    required this.title,
    required this.body,
    this.userId = 1,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: int.tryParse('${json['id']}') ?? 0,
      userId: int.tryParse('${json['userId']}') ?? 1,
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
      };
}
