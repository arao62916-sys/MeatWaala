class AppConstants {
  // App Info
  static const String appName = 'MeatWaala';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Fresh & Hygienic Meat Delivered';

  // Storage Keys
  static const String storageKeyIsFirstTime = 'is_first_time';
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyUserId = 'user_id';
  static const String storageKeyUserData = 'user_data';
  static const String storageKeySelectedCity = 'selected_city';
  static const String storageKeyCart = 'cart_items';
  static const String storageKeySavedAddresses = 'saved_addresses';
  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const int apiTimeout = 30; // seconds

  // Categories
  static const List<String> productCategories = [
    'Chicken',
    'Mutton',
    'Seafood',
    'Marinated',
    'Snacks',
    'Ready to Cook',
  ];

  // Weight Options
  static const List<String> weightOptions = [
    '250g',
    '500g',
    '750g',
    '1kg',
    '1.5kg',
    '2kg',
  ];

  // Delivery Time Slots
  static const List<String> deliveryTimeSlots = [
    '6:00 AM - 9:00 AM',
    '9:00 AM - 12:00 PM',
    '12:00 PM - 3:00 PM',
    '3:00 PM - 6:00 PM',
    '6:00 PM - 9:00 PM',
  ];

  // Payment Methods
  static const List<String> paymentMethods = [
    'Cash on Delivery',
    'Credit/Debit Card',
    'UPI',
    'Net Banking',
  ];

  // Order Status
  static const String orderStatusPending = 'Pending';
  static const String orderStatusConfirmed = 'Confirmed';
  static const String orderStatusProcessing = 'Processing';
  static const String orderStatusOutForDelivery = 'Out for Delivery';
  static const String orderStatusDelivered = 'Delivered';
  static const String orderStatusCancelled = 'Cancelled';

  // Cities
  static const List<String> availableCities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
  ];

  // Validation
  static const int minPasswordLength = 6;
  static const int otpLength = 6;

  // Animation Durations
  static const int splashDuration = 3; // seconds
  static const int animationDuration = 300; // milliseconds
}
