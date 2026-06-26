class CommentModel {
  final String userName;
  final String message;
  final String date;
  final String imageUrl;

  CommentModel({
    required this.userName,
    required this.message,
    required this.date,
    this.imageUrl = '',
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      userName: json['userName'] ?? 'Guest User',
      message: json['message'] ?? '',
      date: json['date'] ?? json['createdAt'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
