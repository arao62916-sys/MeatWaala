import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/network/base_api_service.dart';

class ApiFailureScreen extends StatelessWidget {
  final String? message;
  final String? errorType;

  const ApiFailureScreen({
    Key? key,
    this.message,
    this.errorType,
  }) : super(key: key);

  /// Helper to navigate to failure screen if API fails
  static void handleApiFailure(BuildContext context, ApiResult result) {
    if (!result.success) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ApiFailureScreen(message: result.message),
        ),
      );
    }
  }

  String _getErrorIcon() {
    switch (errorType) {
      case 'offline':
        return '📡';
      case 'timeout':
        return '⏱️';
      case 'server':
        return '🚫';
      default:
        return '⚠️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/failed.png',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              Text(
                _getErrorIcon(),
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              Text(
                message ?? 'Something went wrong! Please try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
