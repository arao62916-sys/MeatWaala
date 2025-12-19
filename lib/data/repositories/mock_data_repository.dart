import 'package:meatwaala_app/data/models/product_model.dart';
import 'package:meatwaala_app/data/models/category_model.dart';

class MockDataRepository {
  // Mock Categories
  static List<CategoryModel> getCategories() {
    return [
      CategoryModel(
        id: '1',
        name: 'Chicken',
        imageUrl: 'https://via.placeholder.com/150',
        description: 'Fresh chicken products',
        productCount: 12,
      ),
      CategoryModel(
        id: '2',
        name: 'Mutton',
        imageUrl: 'https://via.placeholder.com/150',
        description: 'Premium mutton cuts',
        productCount: 8,
      ),
      CategoryModel(
        id: '3',
        name: 'Seafood',
        imageUrl: 'https://via.placeholder.com/150',
        description: 'Fresh from the ocean',
        productCount: 15,
      ),
      CategoryModel(
        id: '4',
        name: 'Marinated',
        imageUrl: 'https://via.placeholder.com/150',
        description: 'Ready to cook marinated items',
        productCount: 10,
      ),
      CategoryModel(
        id: '5',
        name: 'Snacks',
        imageUrl: 'https://via.placeholder.com/150',
        description: 'Delicious meat snacks',
        productCount: 6,
      ),
      CategoryModel(
        id: '6',
        name: 'Ready to Cook',
        imageUrl: 'https://via.placeholder.com/150',
        description: 'Pre-prepared items',
        productCount: 9,
      ),
    ];
  }

  // Mock Products
  static List<ProductModel> getProducts() {
    return [
      ProductModel(
        id: '1',
        name: 'Chicken Breast (Boneless)',
        description:
            'Fresh, tender chicken breast pieces. Perfect for grilling, frying, or curry. High in protein and low in fat.',
        category: 'Chicken',
        imageUrl: 'https://via.placeholder.com/300',
        images: [
          'https://via.placeholder.com/300',
          'https://via.placeholder.com/300',
        ],
        basePrice: 280,
        weightPrices: {
          '250g': 150,
          '500g': 280,
          '1kg': 540,
        },
        availableWeights: ['250g', '500g', '1kg'],
        isAvailable: true,
        isFeatured: true,
        rating: 4.5,
        reviewCount: 128,
        discount: '10% OFF',
      ),
      ProductModel(
        id: '2',
        name: 'Chicken Curry Cut',
        description:
            'Freshly cut chicken with bone, ideal for making delicious curries and traditional dishes.',
        category: 'Chicken',
        imageUrl: 'https://via.placeholder.com/300',
        images: ['https://via.placeholder.com/300'],
        basePrice: 240,
        weightPrices: {
          '500g': 240,
          '1kg': 460,
          '2kg': 900,
        },
        availableWeights: ['500g', '1kg', '2kg'],
        isAvailable: true,
        isFeatured: true,
        rating: 4.7,
        reviewCount: 256,
      ),
      ProductModel(
        id: '3',
        name: 'Mutton Curry Cut',
        description:
            'Premium quality mutton with bone, perfect for biryanis and curries. Tender and flavorful.',
        category: 'Mutton',
        imageUrl: 'https://via.placeholder.com/300',
        images: ['https://via.placeholder.com/300'],
        basePrice: 650,
        weightPrices: {
          '500g': 650,
          '1kg': 1280,
        },
        availableWeights: ['500g', '1kg'],
        isAvailable: true,
        isFeatured: true,
        rating: 4.8,
        reviewCount: 89,
      ),
      ProductModel(
        id: '4',
        name: 'Prawns (Medium)',
        description:
            'Fresh medium-sized prawns, cleaned and deveined. Perfect for frying or curry.',
        category: 'Seafood',
        imageUrl: 'https://via.placeholder.com/300',
        images: ['https://via.placeholder.com/300'],
        basePrice: 450,
        weightPrices: {
          '250g': 450,
          '500g': 880,
          '1kg': 1700,
        },
        availableWeights: ['250g', '500g', '1kg'],
        isAvailable: true,
        isFeatured: false,
        rating: 4.6,
        reviewCount: 67,
      ),
      ProductModel(
        id: '5',
        name: 'Fish Fillet (Basa)',
        description:
            'Boneless fish fillets, ready to cook. Mild flavor and tender texture.',
        category: 'Seafood',
        imageUrl: 'https://via.placeholder.com/300',
        images: ['https://via.placeholder.com/300'],
        basePrice: 380,
        weightPrices: {
          '250g': 380,
          '500g': 740,
          '1kg': 1450,
        },
        availableWeights: ['250g', '500g', '1kg'],
        isAvailable: true,
        isFeatured: true,
        rating: 4.4,
        reviewCount: 145,
      ),
      ProductModel(
        id: '6',
        name: 'Tandoori Chicken (Marinated)',
        description:
            'Pre-marinated chicken in authentic tandoori spices. Just cook and enjoy!',
        category: 'Marinated',
        imageUrl: 'https://via.placeholder.com/300',
        images: ['https://via.placeholder.com/300'],
        basePrice: 320,
        weightPrices: {
          '500g': 320,
          '1kg': 620,
        },
        availableWeights: ['500g', '1kg'],
        isAvailable: true,
        isFeatured: true,
        rating: 4.9,
        reviewCount: 234,
        discount: '15% OFF',
      ),
      ProductModel(
        id: '7',
        name: 'Chicken Seekh Kebab',
        description:
            'Ready to cook chicken seekh kebabs with aromatic spices. Perfect for grilling.',
        category: 'Snacks',
        imageUrl: 'https://via.placeholder.com/300',
        images: ['https://via.placeholder.com/300'],
        basePrice: 280,
        weightPrices: {
          '250g': 280,
          '500g': 540,
        },
        availableWeights: ['250g', '500g'],
        isAvailable: true,
        isFeatured: false,
        rating: 4.7,
        reviewCount: 98,
      ),
      ProductModel(
        id: '8',
        name: 'Mutton Keema',
        description:
            'Freshly minced mutton, perfect for keema curry, kebabs, and stuffing.',
        category: 'Mutton',
        imageUrl: 'https://via.placeholder.com/300',
        images: ['https://via.placeholder.com/300'],
        basePrice: 580,
        weightPrices: {
          '250g': 580,
          '500g': 1140,
          '1kg': 2250,
        },
        availableWeights: ['250g', '500g', '1kg'],
        isAvailable: true,
        isFeatured: false,
        rating: 4.6,
        reviewCount: 76,
      ),
    ];
  }

  // Get products by category
  static List<ProductModel> getProductsByCategory(String category) {
    return getProducts().where((p) => p.category == category).toList();
  }

  // Get featured products
  static List<ProductModel> getFeaturedProducts() {
    return getProducts().where((p) => p.isFeatured).toList();
  }

  // Get product by ID
  static ProductModel? getProductById(String id) {
    try {
      return getProducts().firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Mock Banners
  static List<String> getBanners() {
    return [
      'https://via.placeholder.com/800x300/D32F2F/FFFFFF?text=Fresh+Meat+Delivered',
      'https://via.placeholder.com/800x300/B71C1C/FFFFFF?text=Premium+Quality',
      'https://via.placeholder.com/800x300/EF5350/FFFFFF?text=Special+Offers',
    ];
  }
}
