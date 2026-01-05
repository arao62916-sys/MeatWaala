import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/core/widgets/custom_button.dart';
import 'package:meatwaala_app/modules/onboarding/controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: controller.skip,
                  child: const Text('Skip'),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.pages.length,
                itemBuilder: (context, index) {
                  final page = controller.pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image or Lottie
                        if (page.imageAsset != null)
                          Image.asset(
                            page.imageAsset!,
                            height: 150,
                          )
                        else if (page.lottieAsset != null)
                          Lottie.asset(
                            page.lottieAsset!,
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                        const SizedBox(height: 48),
                        // Title
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Description
                        Text(
                          page.description,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicator
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SmoothPageIndicator(
                controller: controller.pageController,
                count: controller.pages.length,
                effect: const WormEffect(
                  dotColor: AppColors.border,
                  activeDotColor: AppColors.primary,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
            ),

            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Obx(() => CustomButton(
                    text: controller.currentPage.value ==
                            controller.pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: controller.next,
                    width: double.infinity,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}