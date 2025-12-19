import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/core/widgets/custom_button.dart';
import 'package:meatwaala_app/modules/location/controllers/location_controller.dart';

class LocationView extends GetView<LocationController> {
  const LocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search city...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // City List
          Expanded(
            child: Obx(() {
              final cities = controller.filteredCities;
              return ListView.builder(
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  final city = cities[index];
                  return Obx(() => RadioListTile<String>(
                        title: Text(city),
                        value: city,
                        groupValue: controller.selectedCity.value,
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectCity(value);
                          }
                        },
                        activeColor: AppColors.primary,
                      ));
                },
              );
            }),
          ),

          // Confirm Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              text: 'Confirm Location',
              onPressed: controller.confirmLocation,
              width: double.infinity,
              icon: Icons.check,
            ),
          ),
        ],
      ),
    );
  }
}
