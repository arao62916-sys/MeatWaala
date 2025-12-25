import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // ================== KEYS ==================
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _isLoggedInKey = 'is_logged_in';

  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';
  static const String _userRoleKey = 'user_role';

  static const String _userDataKey = 'user_data';
  static const String _tempEmailKey = 'temp_email';
  static const String _introSeenKey = 'intro_seen';

  // ================== INTRO ==================
  static Future<void> setIntroSeen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introSeenKey, value);
  }

  static Future<bool> isIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_introSeenKey) ?? false;
  }

  // ================== LOGIN ==================
  static Future<void> saveLoginData({
    required String token,
    required String userId,
    required String userName,
    String? userEmail,
    String? userPhone,
    String? refreshToken,
    String? userRole,
    Map<String, dynamic>? fullUserData,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, userName);

    if (userEmail != null) {
      await prefs.setString(_userEmailKey, userEmail);
    }

    if (userPhone != null) {
      await prefs.setString(_userPhoneKey, userPhone);
    }

    if (userRole != null) {
      await prefs.setString(_userRoleKey, userRole);
    }

    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }

    if (fullUserData != null) {
      await prefs.setString(_userDataKey, jsonEncode(fullUserData));
    }

    await prefs.setBool(_isLoggedInKey, true);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // ================== GETTERS ==================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhoneKey);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userDataKey);
    if (data == null) return null;
    return jsonDecode(data);
  }

  static Future<Map<String, dynamic>> getAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString(_tokenKey),
      'userId': prefs.getString(_userIdKey),
      'userName': prefs.getString(_userNameKey),
      'userEmail': prefs.getString(_userEmailKey),
      'userPhone': prefs.getString(_userPhoneKey),
      'userRole': prefs.getString(_userRoleKey),
      'refreshToken': prefs.getString(_refreshTokenKey),
    };
  }

  // ================== TEMP EMAIL ==================
  static Future<void> saveTempEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tempEmailKey, email);
  }

  static Future<String?> getTempEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tempEmailKey);
  }

  static Future<void> clearTempEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tempEmailKey);
  }

  // ================== LOGOUT / CLEAR ==================
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userDataKey);

    await prefs.setBool(_isLoggedInKey, false);
  }

  // ================== DEBUG ==================
  static Future<void> debugPrintStorage() async {
    final prefs = await SharedPreferences.getInstance();
    print('🧠 STORAGE DEBUG');
    print('🔐 Token: ${prefs.getString(_tokenKey)}');
    print('🆔 UserId: ${prefs.getString(_userIdKey)}');
    print('👤 Name: ${prefs.getString(_userNameKey)}');
    print('📧 Email: ${prefs.getString(_userEmailKey)}');
    print('📞 Phone: ${prefs.getString(_userPhoneKey)}');
    print('🎭 Role: ${prefs.getString(_userRoleKey)}');
    print('🔁 RefreshToken: ${prefs.getString(_refreshTokenKey)}');
    print('✅ LoggedIn: ${prefs.getBool(_isLoggedInKey)}');
  }
}
