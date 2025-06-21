class Product {
  final String id;
  final String name;
  final String price;
  final bool isBestSeller;
  final String category;
  final List<String> sizes;
  final String description;
  final double rating;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.isBestSeller,
    required this.category,
    required this.sizes,
    required this.description,
    required this.rating,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String baseUrl = 'http://13.60.243.207/storage/';
    String? imagePath;

    // Extract image path from the images array
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      final imagesList = json['images'] as List;

      // First, try to find the featured image
      for (var imageData in imagesList) {
        if (imageData is Map<String, dynamic> &&
            imageData['is_featured'] == 1) {
          imagePath = imageData['image_path'];
          break;
        }
      }

      // If no featured image found, use the first image
      if (imagePath == null && imagesList.isNotEmpty) {
        final firstImage = imagesList.first;
        if (firstImage is Map<String, dynamic>) {
          imagePath = firstImage['image_path'];
        }
      }
    }

    // Fallback to direct image_path field if images array doesn't exist
    if (imagePath == null) {
      imagePath = json['image_path'];
    }

    return Product(
      id: json['id'].toString(),
      name: json['product_name'] ?? '',
      price: (json['sale_price'] ?? json['original_price'] ?? '0').toString(),
      isBestSeller: json['Bestseller'] == true,
      category: json['category'] is Map
          ? (json['category']['category_name'] ?? '')
          : (json['category'] ?? ''),
      sizes: json['size'] != null
          ? json['size'].toString().split(',').map((s) => s.trim()).toList()
          : [],
      description: json['product_desc'] ?? '',
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      image: imagePath != null && imagePath.startsWith('http')
          ? imagePath
          : baseUrl + (imagePath ?? 'default-image.png'),
    );
  }
}
