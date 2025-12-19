import 'package:get/get.dart';

class BottomNavController extends GetxController {
  // Reactive selected tab index
  final RxInt selectedIndex = 0.obs;

  // Change tab method
  void changeTab(int index) {
    selectedIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize with Home tab selected
    selectedIndex.value = 0;
  }
}
