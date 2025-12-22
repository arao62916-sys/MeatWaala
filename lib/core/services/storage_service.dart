import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userRoleKey = 'user_role';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _refreshTokenKey = 'refresh_token';

  //showing intro screen
  static const String _introSeenKey = 'intro_seen';
  static Future<void> setIntroSeen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introSeenKey, value);
  }

  static Future<bool> isIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_introSeenKey) ?? false;
  }
  // end intro screen

  // Cached login status
  static bool cachedLoginStatus = false;

  /// Initialize storage (call in main before runApp)
  // static Future<void> init() async {
  //   print('🔍 Initializing StorageService... 👍');
  //   cachedLoginStatus = await isLoggedIn();
  // }

  static Future<void> saveLoginData({
    required String token,
    required String userId,
    required String userName,

    String refreshToken = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, userName);
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_refreshTokenKey, refreshToken);

    cachedLoginStatus = true;
  }

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

  static Future<Map<String, dynamic>> getAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString(_tokenKey),
      'userId': prefs.getString(_userIdKey),
      'userName': prefs.getString(_userNameKey),
    };
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  static Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.setBool(_isLoggedInKey, false);

    cachedLoginStatus = false;
  }

  /// Save login response map directly
  static Future<void> saveLoginResponse(Map<String, dynamic> response) async {
    final data = response['data'];
    if (data != null) {
      await saveLoginData(
        token: data['token'] ?? '',
        userId: data['userId'] ?? '',
        userName: data['userName'] ?? '',
      );
    }
  }
}
