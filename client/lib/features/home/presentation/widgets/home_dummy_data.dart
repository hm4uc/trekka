class Place {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? tag;
  final String price;

  const Place({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.tag,
    this.price = "",
  });
}

// Dữ liệu mẫu
class HomeMockData {
  static const List<Map<String, dynamic>> categories = [
    {"icon": "☕", "label": "Cafe học bài"},
    {"icon": "💕", "label": "Hẹn hò"},
    {"icon": "📸", "label": "Sống ảo"},
    {"icon": "🍻", "label": "Nhậu nhẹt"},
    {"icon": "⛺", "label": "Camping"}, // Dùng icon material sau
  ];

  static const List<Place> aiRecommendations = [
    Place(title: "Sapa mùa săn mây", subtitle: "Phù hợp sở thích 'Thiên nhiên' của bạn", imageUrl: "assets/images/welcome.jpg"), // Dùng ảnh có sẵn
    Place(title: "Đà Lạt phố sương", subtitle: "Dựa trên độ tuổi 20-25", imageUrl: "assets/images/mountain.jpg"),
  ];

  static const List<Place> trending = [
    Place(title: "Cầu Hôn Phú Quốc", subtitle: "Check-in hot nhất tuần", imageUrl: "assets/images/umbrella-beach.jpg", tag: "🔥 Top 1"),
    Place(title: "Phố đường tàu", subtitle: "Hà Nội", imageUrl: "assets/images/onboarding_intro_4.jpg", tag: "Hot"),
    Place(title: "Hẻm bia Lost in HongKong", subtitle: "Sài Gòn", imageUrl: "assets/images/shopping_bag.jpg"),
  ];

  static const List<Place> budget = [
    Place(title: "Foodtour Hải Phòng", subtitle: "Ăn sập cảng", price: "500k", imageUrl: "assets/images/utensils.jpg"),
    Place(title: "Camping hồ Trị An", subtitle: "Cuối tuần", price: "800k", imageUrl: "assets/images/hiking.jpg"),
    Place(title: "Tà Xùa săn mây", subtitle: "2N1Đ", price: "1tr5", imageUrl: "assets/images/mountain.jpg"),
    Place(title: "Staycation 5 sao", subtitle: "Nghỉ dưỡng", price: "3tr", imageUrl: "assets/images/gem.jpg"),
  ];

  static const List<Place> food = [
    Place(title: "Phở Thìn Lò Đúc", subtitle: "Hà Nội", imageUrl: "assets/images/utensils.jpg"),
    Place(title: "Bánh mì Phượng", subtitle: "Hội An", imageUrl: "assets/images/umbrella-beach.jpg"),
  ];
}