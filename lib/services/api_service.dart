import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  // [GANTI-SOAL 1 - ENDPOINT API]: Base URL DummyJSON Products API
  static const String baseUrl = 'https://dummyjson.com';

  // [GANTI-SOAL 1 - ENDPOINT API]: Mengambil daftar kategori dari GET /products/category-list
  Future<List<String>> getCategories() async {
    final uri = Uri.parse('$baseUrl/products/category-list');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((e) => e.toString()).toList();
      }
      return _fallbackCategories;
    } catch (e) {
      debugPrint(
          'Gagal mengambil kategori online: $e. Menggunakan fallback kategori.');
      return _fallbackCategories;
    }
  }

  // [GANTI-SOAL 1 - ENDPOINT API]: Mengambil daftar produk (minimal 10 produk)
  // Mendukung filter kategori via GET /products/category/{category} dan pencarian
  Future<List<Product>> getProducts({
    String? category,
    String? query,
    int limit = 30,
  }) async {
    Uri uri;

    if (query != null && query.trim().isNotEmpty) {
      uri = Uri.parse(
          '$baseUrl/products/search?q=${Uri.encodeComponent(query.trim())}');
    } else if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all') {
      uri = Uri.parse(
          '$baseUrl/products/category/${Uri.encodeComponent(category.trim())}');
    } else {
      uri = Uri.parse('$baseUrl/products?limit=$limit');
    }

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // [GANTI-SOAL 1 - ENDPOINT API]: Key pembungkus list produk pada DummyJSON adalah 'products'
        final results = data['products'] as List? ?? [];
        return results.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getProducts: $e. Menggunakan data fallback.');
      return _getFallbackProducts(category: category, query: query);
    }
  }

  // [GANTI-SOAL 1 - ENDPOINT API]: GET /products/{id} - mengambil detail satu produk
  Future<Product> getProductDetail(int id) async {
    final uri = Uri.parse('$baseUrl/products/$id');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Produk tidak ditemukan');
      }
    } catch (_) {
      final match = _fallbackProductsList.firstWhere(
        (p) => p['id'] == id,
        orElse: () => _fallbackProductsList.first,
      );
      return Product.fromJson(match);
    }
  }

  // Fallback data jika offline saat ujian
  static const List<String> _fallbackCategories = [
    'beauty',
    'fragrances',
    'furniture',
    'groceries',
    'home-decoration',
    'kitchen-accessories',
    'laptops',
    'smartphones',
    'tops',
    'womens-shoes',
  ];

  List<Product> _getFallbackProducts({String? category, String? query}) {
    List<Map<String, dynamic>> filtered = List.from(_fallbackProductsList);
    if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all') {
      filtered = filtered
          .where((item) =>
              (item['category'] as String).toLowerCase() ==
              category.toLowerCase())
          .toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      filtered = filtered.where((item) {
        final title = (item['title'] as String).toLowerCase();
        final brand = (item['brand'] as String? ?? '').toLowerCase();
        return title.contains(q) || brand.contains(q);
      }).toList();
    }
    return filtered.map((item) => Product.fromJson(item)).toList();
  }

  static final List<Map<String, dynamic>> _fallbackProductsList = [
    {
      'id': 1,
      'title': 'Essence Mascara Lash Princess',
      'description':
          'The Essence Mascara Lash Princess is a popular mascara known for its volumizing and lengthening effects.',
      'category': 'beauty',
      'price': 9.99,
      'discountPercentage': 10.48,
      'rating': 4.56,
      'stock': 99,
      'brand': 'Essence',
      'thumbnail':
          'https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/thumbnail.webp',
      'images': [
        'https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/1.webp'
      ]
    },
    {
      'id': 2,
      'title': 'Eyeshadow Palette with Mirror',
      'description':
          'The Eyeshadow Palette with Mirror offers a versatile range of eyeshadow shades for creating stunning eye looks.',
      'category': 'beauty',
      'price': 19.99,
      'discountPercentage': 18.19,
      'rating': 4.86,
      'stock': 34,
      'brand': 'Glamour Beauty',
      'thumbnail':
          'https://cdn.dummyjson.com/product-images/beauty/eyeshadow-palette-with-mirror/thumbnail.webp',
      'images': [
        'https://cdn.dummyjson.com/product-images/beauty/eyeshadow-palette-with-mirror/1.webp'
      ]
    },
    {
      'id': 3,
      'title': 'Powder Canister',
      'description':
          'The Powder Canister is a finely milled setting powder designed to set makeup and control shine.',
      'category': 'beauty',
      'price': 14.99,
      'discountPercentage': 18.14,
      'rating': 4.82,
      'stock': 59,
      'brand': 'Velvet Touch',
      'thumbnail':
          'https://cdn.dummyjson.com/product-images/beauty/powder-canister/thumbnail.webp',
      'images': [
        'https://cdn.dummyjson.com/product-images/beauty/powder-canister/1.webp'
      ]
    },
    {
      'id': 4,
      'title': 'Red Lipstick',
      'description':
          'The Red Lipstick is a classic and bold choice for adding a pop of color to your lips.',
      'category': 'beauty',
      'price': 12.99,
      'discountPercentage': 19.03,
      'rating': 4.51,
      'stock': 68,
      'brand': 'Chic Cosmetics',
      'thumbnail':
          'https://cdn.dummyjson.com/product-images/beauty/red-lipstick/thumbnail.webp',
      'images': [
        'https://cdn.dummyjson.com/product-images/beauty/red-lipstick/1.webp'
      ]
    },
    {
      'id': 5,
      'title': 'Red Nail Polish',
      'description':
          'The Red Nail Polish offers a rich and glossy finish for vibrant and polished nails.',
      'category': 'beauty',
      'price': 8.99,
      'discountPercentage': 2.46,
      'rating': 4.91,
      'stock': 71,
      'brand': 'Nail Couture',
      'thumbnail':
          'https://cdn.dummyjson.com/product-images/beauty/red-nail-polish/thumbnail.webp',
      'images': [
        'https://cdn.dummyjson.com/product-images/beauty/red-nail-polish/1.webp'
      ]
    },
    {
      'id': 6,
      'title': 'Calvin Klein CK One',
      'description':
          'CK One by Calvin Klein is an iconic, universally loved fragrance with fresh green tea and citrus notes.',
      'category': 'fragrances',
      'price': 49.99,
      'discountPercentage': 0.32,
      'rating': 4.85,
      'stock': 17,
      'brand': 'Calvin Klein',
      'thumbnail':
          'https://cdn.dummyjson.com/product-images/fragrances/calvin-klein-ck-one/thumbnail.webp',
      'images': [
        'https://cdn.dummyjson.com/product-images/fragrances/calvin-klein-ck-one/1.webp'
      ]
    },
    {
      'id': 7,
      'title': 'Chanel Coco Noir Eau De',
      'description':
          'Coco Noir by Chanel is an elegant and mysterious fragrance with notes of grapefruit, rose, and patchouli.',
      'category': 'fragrances',
      'price': 129.99,
      'discountPercentage': 18.64,
      'rating': 4.76,
      'stock': 41,
      'brand': 'Chanel',
      'thumbnail':
          'https://cdn.dummyjson.com/product-images/fragrances/chanel-coco-noir-eau-de/thumbnail.webp',
      'images': [
        'https://cdn.dummyjson.com/product-images/fragrances/chanel-coco-noir-eau-de/1.webp'
      ]
    },
    {
      'id': 8,
      'title': 'Dior J\'adore',
      'description':
          'J\'adore by Dior is a luxurious and floral fragrance with notes of ylang-ylang, Damascus rose, and jasmine.',
      'category': 'fragrances',
      'price': 89.99,
      'discountPercentage': 17.44,
      'rating': 4.7,
      'stock': 91,
      'brand': 'Dior',
      'thumbnail':
          'https://cdn.dummyjson.com/product-images/fragrances/dior-j-adore/thumbnail.webp',
      'images': [
        'https://cdn.dummyjson.com/product-images/fragrances/dior-j-adore/1.webp'
      ]
    },
    {
      'id': 9,
      'title': 'Annibale Colombo Bed',
      'description':
          'The Annibale Colombo Bed is a luxurious and artfully crafted bed frame with high-end Italian design.',
      'category': 'furniture',
      'price': 1899.99,
      'discountPercentage': 0.29,
      'rating': 4.14,
      'stock': 47,
      'brand': 'Annibale Colombo',
      'thumbnail':
          'https://cdn.dummyjson.com/product-images/furniture/annibale-colombo-bed/thumbnail.webp',
      'images': [
        'https://cdn.dummyjson.com/product-images/furniture/annibale-colombo-bed/1.webp'
      ]
    },
    {
      'id': 10,
      'title': 'Annibale Colombo Sofa',
      'description':
          'The Annibale Colombo Sofa is a sophisticated and comfortable seating option with premium upholstery.',
      'category': 'furniture',
      'price': 2499.99,
      'discountPercentage': 18.54,
      'rating': 4.72,
      'stock': 16,
      'brand': 'Annibale Colombo',
      'thumbnail':
          'https://cdn.dummyjson.com/product-images/furniture/annibale-colombo-sofa/thumbnail.webp',
      'images': [
        'https://cdn.dummyjson.com/product-images/furniture/annibale-colombo-sofa/1.webp'
      ]
    },
    {
      'id': 11,
      'title': 'Bedside Table African Cherry',
      'description':
          'The Bedside Table in African Cherry is a stylish and functional addition to any modern bedroom.',
      'category': 'furniture',
      'price': 299.99,
      'discountPercentage': 9.58,
      'rating': 4.48,
      'stock': 16,
      'brand': 'Classic Wood',
      'thumbnail':
          'https://cdn.dummyjson.com/product-images/furniture/bedside-table-african-cherry/thumbnail.webp',
      'images': [
        'https://cdn.dummyjson.com/product-images/furniture/bedside-table-african-cherry/1.webp'
      ]
    },
    {
      'id': 12,
      'title': 'Knoll Saarinen Executive Chair',
      'description':
          'The Knoll Saarinen Executive Chair is an iconic mid-century modern design combining style and ergonomics.',
      'category': 'furniture',
      'price': 499.99,
      'discountPercentage': 15.23,
      'rating': 4.11,
      'stock': 47,
      'brand': 'Knoll',
      'thumbnail':
          'https://cdn.dummyjson.com/product-images/furniture/knoll-saarinen-executive-chair/thumbnail.webp',
      'images': [
        'https://cdn.dummyjson.com/product-images/furniture/knoll-saarinen-executive-chair/1.webp'
      ]
    },
  ];
}
