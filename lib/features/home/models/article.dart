class Article {
  final String id;
  final String authorId;
  final String title;
  final String preview;
  final String coverUrl;
  final String tag;
  final String authorName;
  final String authorAvatarUrl;
  final String date;
  final String readTime;
  final int likes;
  final int comments;
  final int views;

  const Article({
    required this.id,
    this.authorId = '',
    required this.title,
    required this.preview,
    required this.coverUrl,
    required this.tag,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.date,
    required this.readTime,
    this.likes = 0,
    this.comments = 0,
    this.views = 0,
  });
}