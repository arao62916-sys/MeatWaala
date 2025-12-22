import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _storage = GetStorage();

  // Storage Keys
  static const String _keyIsFirstTime = 'is_first_time';
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserData = 'user_data';
  static const String _keyCompanyData = 'company_data';
  static const String _keySelectedAreaId = 'selected_area_id';
  static const String _keySelectedAreaName = 'selected_area_name';
  static const String _keyCart = 'cart_items';
  static const String _keyTempEmail = 'temp_email'; // For signup to login flow

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
  }) async {
    await _storage.write(_keyToken, token);
    await _storage.write(_keyUserId, customerId);
    await _storage.write(_keyUserData, jsonEncode(customerData));
  }

  String? getToken() {
    return _storage.read<String>(_keyToken);
  }

  String? getUserId() {
    return _storage.read<String>(_keyUserId);
  }

  Map<String, dynamic>? getUserData() {
    final data = _storage.read<String>(_keyUserData);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  bool isLoggedIn() {
    final token = _storage.read<String>(_keyToken);
    return token != null && token.isNotEmpty;
  }

  Future<void> clearUserData() async {
    await _storage.remove(_keyToken);
    await _storage.remove(_keyUserId);
    await _storage.remove(_keyUserData);
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
}
