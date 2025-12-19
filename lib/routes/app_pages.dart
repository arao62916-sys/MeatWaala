import 'package:get/get.dart';
import 'package:meatwaala_app/modules/splash/bindings/splash_binding.dart';
import 'package:meatwaala_app/modules/splash/views/splash_view.dart';
import 'package:meatwaala_app/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:meatwaala_app/modules/onboarding/views/onboarding_view.dart';
import 'package:meatwaala_app/modules/auth/bindings/auth_binding.dart';
import 'package:meatwaala_app/modules/auth/views/login_view.dart';
import 'package:meatwaala_app/modules/auth/views/signup_view.dart';
import 'package:meatwaala_app/modules/auth/views/otp_view.dart';
import 'package:meatwaala_app/modules/location/bindings/location_binding.dart';
import 'package:meatwaala_app/modules/location/views/location_view.dart';
import 'package:meatwaala_app/modules/navigation/bindings/bottom_nav_binding.dart';
import 'package:meatwaala_app/modules/navigation/views/main_screen.dart';
import 'package:meatwaala_app/modules/home/bindings/home_binding.dart';
import 'package:meatwaala_app/modules/home/views/home_view.dart';
import 'package:meatwaala_app/modules/categories/bindings/categories_binding.dart';
import 'package:meatwaala_app/modules/categories/views/categories_view.dart';
import 'package:meatwaala_app/modules/products/bindings/product_binding.dart';
import 'package:meatwaala_app/modules/products/views/product_list_view.dart';
import 'package:meatwaala_app/modules/products/views/product_detail_view.dart';
import 'package:meatwaala_app/modules/cart/bindings/cart_binding.dart';
import 'package:meatwaala_app/modules/cart/views/cart_view.dart';
import 'package:meatwaala_app/modules/checkout/bindings/checkout_binding.dart';
import 'package:meatwaala_app/modules/checkout/views/checkout_view.dart';
import 'package:meatwaala_app/modules/orders/bindings/orders_binding.dart';
import 'package:meatwaala_app/modules/orders/views/order_success_view.dart';
import 'package:meatwaala_app/modules/orders/views/order_history_view.dart';
import 'package:meatwaala_app/modules/profile/bindings/profile_binding.dart';
import 'package:meatwaala_app/modules/profile/views/profile_view.dart';
import 'package:meatwaala_app/modules/static_pages/views/static_pages_views.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.location,
      page: () => const LocationView(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainScreen(),
      binding: BottomNavBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.categories,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
    ),
    GetPage(
      name: AppRoutes.productList,
      page: () => const ProductListView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.orderSuccess,
      page: () => const OrderSuccessView(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: AppRoutes.orderHistory,
      page: () => const OrderHistoryView(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.aboutUs,
      page: () => const AboutUsView(),
    ),
    GetPage(
      name: AppRoutes.contactUs,
      page: () => const ContactUsView(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyView(),
    ),
    GetPage(
      name: AppRoutes.terms,
      page: () => const TermsView(),
    ),
  ];
}
