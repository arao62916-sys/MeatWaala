import 'dart:convert';
import 'package:get_storage/get_storage.dart';

/// Profile Validation Result
class ProfileValidationResult {
  final bool isComplete;
  final List<String> missingFields;
  final String? name;
  final String? mobile;
  final String? email;
  final String? areaId;

  ProfileValidationResult({
    required this.isComplete,
    required this.missingFields,
    this.name,
    this.mobile,
    this.email,
    this.areaId,
  });

  String get missingFieldsMessage {
    if (missingFields.isEmpty) return '';
    return 'Missing: ${missingFields.join(', ')}';
  }
}

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _storage = GetStorage();

  // Storage Keys
  static const String _keyIsFirstTime = 'is_first_time';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserData = 'user_data';
  static const String _keyCompanyData = 'company_data';
  static const String _keySelectedAreaId = 'selected_area_id';
  static const String _keySelectedAreaName = 'selected_area_name';
  static const String _keyTempEmail = 'temp_email'; // For signup to login flow
  // TODO: Implement cart storage
  // static const String _keyCart = 'cart_items';

  // Initialize storage
  static Future<void> init() async {
    await GetStorage.init();
  }

  // Generic methods
  Future<void> write(String key, dynamic value) async {
    await _storage.write(key, value);
  }

  T? read<T>(String key) {
    return _storage.read<T>(key);
  }

  Future<void> remove(String key) async {
    await _storage.remove(key);
  }

  Future<void> clear() async {
    await _storage.erase();
  }

  bool hasData(String key) {
    return _storage.hasData(key);
  }

  // ============ COMPANY DATA ============
  Future<void> saveCompanyData(Map<String, dynamic> companyData) async {
    await _storage.write(_keyCompanyData, jsonEncode(companyData));
  }

  Map<String, dynamic>? getCompanyData() {
    final data = _storage.read<String>(_keyCompanyData);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  String? getCompanyLogo() {
    final data = getCompanyData();
    return data?['logo_url'];
  }

  String? getCompanyName() {
    final data = getCompanyData();
    return data?['display_name'];
  }

  // ============ AREA DATA ============
  Future<void> saveSelectedArea(
      {required String areaId, required String areaName}) async {
    await _storage.write(_keySelectedAreaId, areaId);
    await _storage.write(_keySelectedAreaName, areaName);
  }

  String? getSelectedAreaId() {
    return _storage.read<String>(_keySelectedAreaId);
  }

  String? getSelectedAreaName() {
    return _storage.read<String>(_keySelectedAreaName);
  }

  bool hasSelectedArea() {
    return _storage.hasData(_keySelectedAreaId);
  }

  // ============ USER/AUTH DATA ============
  Future<void> saveUserData({
    required String token,
    required String customerId,
    required Map<String, dynamic> customerData,
    String? refreshToken,
  }) async {
    // Write all data synchronously for atomicity
    _storage.write(_keyToken, token);
    _storage.write(_keyUserId, customerId);
    _storage.write(_keyUserData, jsonEncode(customerData));

    // Save individual fields for easy access
    if (customerData['name'] != null) {
      _storage.write(_keyUserName, customerData['name']);
    }
    if (customerData['emailId'] != null || customerData['email_id'] != null) {
      _storage.write(
          _keyUserEmail, customerData['emailId'] ?? customerData['email_id']);
    }
    if (customerData['mobile'] != null || customerData['phone'] != null) {
      _storage.write(
          _keyUserPhone, customerData['mobile'] ?? customerData['phone']);
    }
    if (customerData['role'] != null) {
      _storage.write(_keyUserRole, customerData['role']);
    }
    if (refreshToken != null) {
      _storage.write(_keyRefreshToken, refreshToken);
    }

    // CRITICAL: Set isLoggedIn flag LAST
    _storage.write(_keyIsLoggedIn, true);

    // Force GetStorage to persist to disk
    await _storage.save();

    // Ensure writes are flushed
    await Future.delayed(const Duration(milliseconds: 50));
  }

  // Alternative method for compatibility with SharedPreferences-style calls
  Future<void> saveLoginData({
    required String token,
    required String userId,
    required String userName,
    String? userEmail,
    String? userPhone,
    String? refreshToken,
    String? userRole,
    Map<String, dynamic>? fullUserData,
  }) async {
    // Write all data synchronously to ensure atomicity
    _storage.write(_keyToken, token);
    _storage.write(_keyUserId, userId);
    _storage.write(_keyUserName, userName);

    if (userEmail != null) {
      _storage.write(_keyUserEmail, userEmail);
    }
    if (userPhone != null) {
      _storage.write(_keyUserPhone, userPhone);
    }
    if (userRole != null) {
      _storage.write(_keyUserRole, userRole);
    }
    if (refreshToken != null) {
      _storage.write(_keyRefreshToken, refreshToken);
    }
    if (fullUserData != null) {
      _storage.write(_keyUserData, jsonEncode(fullUserData));
    }

    // CRITICAL: Set isLoggedIn flag LAST and ensure it's written
    _storage.write(_keyIsLoggedIn, true);

    // Force GetStorage to persist to disk immediately
    await _storage.save();

    // Additional safety delay to ensure filesystem writes complete
    await Future.delayed(const Duration(milliseconds: 50));
  }

  String? getToken() {
    return _storage.read<String>(_keyToken);
  }

  String? getRefreshToken() {
    return _storage.read<String>(_keyRefreshToken);
  }

  String? getUserId() {
    return _storage.read<String>(_keyUserId);
  }

  String? getUserName() {
    return _storage.read<String>(_keyUserName);
  }

  String? getUserEmail() {
    return _storage.read<String>(_keyUserEmail);
  }

  String? getUserPhone() {
    return _storage.read<String>(_keyUserPhone);
  }

  String? getUserRole() {
    return _storage.read<String>(_keyUserRole);
  }

  Map<String, dynamic>? getUserData() {
    final data = _storage.read<String>(_keyUserData);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Map<String, dynamic> getAllUserData() {
    return {
      'token': _storage.read<String>(_keyToken),
      'userId': _storage.read<String>(_keyUserId),
      'userName': _storage.read<String>(_keyUserName),
      'userEmail': _storage.read<String>(_keyUserEmail),
      'userPhone': _storage.read<String>(_keyUserPhone),
      'userRole': _storage.read<String>(_keyUserRole),
      'refreshToken': _storage.read<String>(_keyRefreshToken),
    };
  }

  bool isLoggedIn() {
    final isLoggedIn = _storage.read<bool>(_keyIsLoggedIn) ?? false;
    final token = _storage.read<String>(_keyToken);
    // User is logged in if flag is set AND token exists
    return isLoggedIn && token != null && token.isNotEmpty;
  }

  Future<void> clearUserData() async {
    await _storage.remove(_keyToken);
    await _storage.remove(_keyRefreshToken);
    await _storage.remove(_keyUserId);
    await _storage.remove(_keyUserName);
    await _storage.remove(_keyUserEmail);
    await _storage.remove(_keyUserPhone);
    await _storage.remove(_keyUserRole);
    await _storage.remove(_keyUserData);
    await _storage.write(_keyIsLoggedIn, false);
  }

  // Logout - clears user data but keeps app data (company, area, etc.)
  Future<void> logout() async {
    await clearUserData();
  }

  // Clear all storage (for debugging or complete reset)
  Future<void> clearAll() async {
    await _storage.erase();
  }

  // ============ TEMP EMAIL (Signup -> Login flow) ============
  Future<void> saveTempEmail(String email) async {
    await _storage.write(_keyTempEmail, email);
  }

  String? getTempEmail() {
    return _storage.read<String>(_keyTempEmail);
  }

  Future<void> clearTempEmail() async {
    await _storage.remove(_keyTempEmail);
  }

  // ============ FIRST TIME CHECK ============
  bool isFirstTime() {
    return _storage.read<bool>(_keyIsFirstTime) ?? true;
  }

  Future<void> setFirstTime(bool value) async {
    await _storage.write(_keyIsFirstTime, value);
  }

  // ============ PROFILE VALIDATION (For Order Submission) ============

  /// Check if profile is complete for order submission
  ProfileValidationResult validateProfileForOrder() {
    final missingFields = <String>[];

    final name = getUserName();
    final mobile = getUserPhone();
    final email = getUserEmail();
    final areaId = getSelectedAreaId();

    if (name == null || name.isEmpty) {
      missingFields.add('Name');
    }
    if (mobile == null || mobile.isEmpty) {
      missingFields.add('Mobile');
    }
    if (email == null || email.isEmpty) {
      missingFields.add('Email');
    }
    if (areaId == null || areaId.isEmpty) {
      missingFields.add('Area');
    }

    return ProfileValidationResult(
      isComplete: missingFields.isEmpty,
      missingFields: missingFields,
      name: name,
      mobile: mobile,
      email: email,
      areaId: areaId,
    );
  }

  /// Check if profile is complete (simple version)
  bool isProfileComplete() {
    return validateProfileForOrder().isComplete;
  }

  /// Get profile data for order submission
  Map<String, String>? getProfileDataForOrder() {
    final validation = validateProfileForOrder();
    if (!validation.isComplete) return null;

    return {
      'name': validation.name!,
      'mobile': validation.mobile!,
      'email_id': validation.email!,
      'area_id': validation.areaId!,
    };
  }

  // ============ DEBUG ============
  void debugPrintStorage() {
    print('🧠 STORAGE DEBUG');
    print('🔐 Token: ${_storage.read<String>(_keyToken)}');
    print('🆔 UserId: ${_storage.read<String>(_keyUserId)}');
    print('👤 Name: ${_storage.read<String>(_keyUserName)}');
    print('📧 Email: ${_storage.read<String>(_keyUserEmail)}');
    print('📞 Phone: ${_storage.read<String>(_keyUserPhone)}');
    print('🎭 Role: ${_storage.read<String>(_keyUserRole)}');
    print('🔁 RefreshToken: ${_storage.read<String>(_keyRefreshToken)}');
    print('✅ LoggedIn Flag: ${_storage.read<bool>(_keyIsLoggedIn)}');
    print('✅ isLoggedIn(): ${isLoggedIn()}');
    print('📍 Area ID: ${_storage.read<String>(_keySelectedAreaId)}');
    print('📍 Area Name: ${_storage.read<String>(_keySelectedAreaName)}');
    print('🔍 Has Token: ${_storage.hasData(_keyToken)}');
    print('🔍 Has UserId: ${_storage.hasData(_keyUserId)}');
  }
}
