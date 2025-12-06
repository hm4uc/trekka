class ImageHelper {
  // Map ID -> Tên file ảnh trong assets/images/
  static String getTravelStyleImage(String id) {
    switch (id) {
      case 'nature': return 'assets/images/mountain.jpg'; // Chú ý tên file bạn cung cấp là moutain hay mountain
      case 'culture_history': return 'assets/images/temple.jpg';
      case 'food_drink': return 'assets/images/utensils.jpg';
      case 'chill_relax': return 'assets/images/umbrella-beach.jpg';
      case 'adventure': return 'assets/images/hiking.jpg';
      case 'shopping_entertainment': return 'assets/images/shopping_bag.jpg';
      case 'luxury': return 'assets/images/gem.jpg';
      case 'local_life': return 'assets/images/home.jpg';
      default: return 'assets/images/trekka_logo_app.png'; // Ảnh fallback
    }
  }

  static String getAgeGroupImage(String ageGroup) {
    switch (ageGroup) {
      case '15-25': return 'assets/images/15_25.jpg';
      case '26-35': return 'assets/images/26_35.jpg';
      case '36-50': return 'assets/images/36_50.jpg';
      case '50+': return 'assets/images/50.jpg';
      default: return 'assets/images/trekka_logo_app.png';
    }
  }
}