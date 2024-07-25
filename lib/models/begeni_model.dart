class DailyLike {
  final int productId;
  final String productName;
  final int likeCount;
  final DateTime date;

  DailyLike({
    required this.productId,
    required this.productName,
    required this.likeCount,
    required this.date,
  });

  factory DailyLike.fromJson(Map<String, dynamic> json) {
    return DailyLike(
      productId: json['productId'],
      productName: json['productName'],
      likeCount: json['likeCount'],
      date: DateTime.parse(json['date']),
    );
  }
}
