import 'dart:convert';

// Model data produk dari DummyJSON API (https://dummyjson.com/products)
class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String thumbnail;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.thumbnail,
    required this.images,
  });

  // Mapping JSON dari response API DummyJSON ke objek Dart
  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = (json['images'] as List).map((e) => e.toString()).toList();
    }

    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String? ?? 'Tidak ada deskripsi.',
      category: json['category'] as String? ?? 'general',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: json['brand'] as String? ?? 'No Brand',
      thumbnail: json['thumbnail'] as String? ??
          (parsedImages.isNotEmpty ? parsedImages.first : ''),
      images: parsedImages,
    );
  }

  // Serialisasi model ke Map/JSON untuk penyimpanan lokal (Wishlist)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'thumbnail': thumbnail,
      'images': images,
    };
  }

  // Helper encode & decode list untuk penyimpanan local storage
  static String encodeList(List<Product> list) =>
      jsonEncode(list.map((c) => c.toJson()).toList());

  static List<Product> decodeList(String str) {
    if (str.isEmpty) return [];
    final Iterable l = jsonDecode(str);
    return List<Product>.from(l.map((model) => Product.fromJson(model)));
  }
}
