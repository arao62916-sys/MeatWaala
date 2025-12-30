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
  static const String logout = 'login/logout';
  static const String forgot_password = 'login/forgot'; // login/forgot/

  // *************** User API *************//
  static const String userProfile = 'login/profile'; //(customer_id)
  static const String updateProfile =
      'login/update'; // (profile update taking customer_id)
  static const String changePassword =
      'login/change-password'; // (customer_id,)

  // *************** Product API *************//
  static const String productCategoryMenu =
      'product/category/menu'; //product/category/menu/
  static const String productCategoryMenuById =
      'product/category/menu'; //product/category/1
  static const String productCategory =
      'product/category/category'; //product/category/category
  static const String productCategoryById =
      'product/category/category/'; // /product/category/category/1
  static const String productCategoryInfo =
      'product/category'; // product/category-info/5
  static const String productCategoryInfoById =
      'product/category-info/'; // product/category-info/1
  static const String productSortOptions = 'product/sort-option';
  static const String productList = 'product/list';
  static const String productInfo = 'product/info/'; //product/info/1
  // *************** Cart API *************//
  static const String cartAdd = 'cart/add'; // cart/add/{customer_id}/{area_id}
  static const String cartDelete =
      'cart/delete'; // cart/delete/{customer_id}/{area_id}?cart_item_id={id}
  static const String cartCount =
      'cart/count'; // cart/count/{customer_id}/{area_id}
  static const String cartInfo =
      'cart/info'; // cart/info/{customer_id}/{area_id}
}
