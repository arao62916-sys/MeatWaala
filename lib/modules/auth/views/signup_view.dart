import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/core/widgets/custom_button.dart';
import 'package:meatwaala_app/core/widgets/custom_text_field.dart';
import 'package:meatwaala_app/modules/auth/controllers/auth_controller.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.signupFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Signup Text
                Text(
                  'Join MeatWaala',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account to get started',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),

                const SizedBox(height: 32),

                // Name Input
                CustomTextField(
                  controller: controller.nameController,
                  hintText: 'Enter your name',
                  labelText: 'Full Name',
                  prefixIcon: Icons.person,
                  validator: controller.validateName,
                ),

                const SizedBox(height: 16),

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

                const SizedBox(height: 16),

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

                const SizedBox(height: 32),

                // Signup Button
                Obx(() => CustomButton(
                      text: 'Sign Up',
                      onPressed: controller.signup,
                      isLoading: controller.isLoading.value,
                      width: double.infinity,
                    )),

                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: controller.navigateToLogin,
                      child: const Text('Login'),
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
