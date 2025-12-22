// core/constants/network_constants_util.dart
class NetworkConstantsUtil {
  // Base URL for MuslimsBright API
  // Keep trailing slash to ensure endpoints concatenate correctly
  static const String baseUrl = "https://www.meatwaala.com/api/";
  static const String Bearer_TOken = "a105e726d4fb80c6216de0c941fb0749";

  static const String Company = 'company';

  static const String Area = 'area';
  static const String areaInfo = 'area-info';  // ?areaId={areaId}
  // *************** Login *************//
  static String signup = 'login/signup'; //  login/signup taking form data (name, email, phone, areaId,)
  static String login = 'login/login'; // (email,password)
  static String logout = 'user/logout';
 }
