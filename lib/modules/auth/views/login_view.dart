import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/core/widgets/custom_button.dart';
import 'package:meatwaala_app/core/widgets/custom_text_field.dart';
import 'package:meatwaala_app/modules/auth/controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Welcome Text
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to continue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),

                const SizedBox(height: 48),

                // Login Method Toggle
                Obx(() => Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Phone',
                            onPressed: () {
                              if (!controller.isPhoneLogin.value) {
                                controller.toggleLoginMethod();
                              }
                            },
                            isOutlined: !controller.isPhoneLogin.value,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            text: 'Email',
                            onPressed: () {
                              if (controller.isPhoneLogin.value) {
                                controller.toggleLoginMethod();
                              }
                            },
                            isOutlined: controller.isPhoneLogin.value,
                          ),
                        ),
                      ],
                    )),

                const SizedBox(height: 32),

                // Phone/Email Input
                Obx(() => controller.isPhoneLogin.value
                    ? CustomTextField(
                        controller: controller.phoneController,
                        hintText: 'Enter phone number',
                        labelText: 'Phone Number',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: controller.validatePhone,
                      )
                    : CustomTextField(
                        controller: controller.emailController,
                        hintText: 'Enter email',
                        labelText: 'Email',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: controller.validateEmail,
                      )),

                const SizedBox(height: 16),

                // Password Input
                Obx(() => CustomTextField(
                      controller: controller.passwordController,
                      hintText: 'Enter password',
                      labelText: 'Password',
                      prefixIcon: Icons.lock,
                      obscureText: controller.obscurePassword.value,
                      suffixIcon: controller.obscurePassword.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      onSuffixIconTap: controller.togglePasswordVisibility,
                      validator: controller.validatePassword,
                    )),

                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                      Get.snackbar(
                        'Info',
                        'Forgot password feature coming soon',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Button
                Obx(() => CustomButton(
                      text: 'Login',
                      onPressed: controller.login,
                      isLoading: controller.isLoading.value,
                      width: double.infinity,
                    )),

                const SizedBox(height: 24),

                // Signup Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: controller.navigateToSignup,
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
