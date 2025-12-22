// core/constants/network_constants_util.dart
class NetworkConstantsUtil {
  // Base URL for MeatWaala API
  // Keep trailing slash to ensure endpoints concatenate correctly
  static const String baseUrl = "https://www.meatwaala.com/api/";
  static const String bearerToken =
      "a105e726d4fb80c6216de0c941fb0749"; // for Authorization header

  // *************** Company API *************//
  static const String company = 'company';

  // *************** Area API *************//
  static const String area = 'area';
  static const String areaInfo = 'area-info'; // ?areaId={areaId}

  // *************** Auth API *************//
  static const String signup =
      'login/signup'; // multipart/form-data (name, email_id, mobile, area_id)
  static const String login = 'login/login'; // (email_id, password)
  static const String logout = 'user/logout';

  // *************** User API *************//
  static const String userProfile = 'user/profile';
  static const String updateProfile = 'user/update-profile';
}
