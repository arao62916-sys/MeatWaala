import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/core/widgets/custom_button.dart';
import 'package:meatwaala_app/data/models/area_model.dart';
import 'package:meatwaala_app/modules/location/controllers/area_controller.dart';
import 'package:meatwaala_app/modules/location/controllers/location_controller.dart';

class LocationView extends GetView<LocationController> {
  const LocationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure AreaController is available
    final areaController = Get.find<AreaController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Area'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: areaController.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search area or PIN code...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    Obx(() => areaController.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: areaController.clearSearch,
                          )
                        : const SizedBox.shrink()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Area List
          Expanded(
            child: Obx(() {
              // Show loading state
              if (areaController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Show error state
              if (areaController.hasError.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        areaController.errorMessage.value,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Retry',
                        onPressed: areaController.fetchAreas,
                        icon: Icons.refresh,
                      ),
                    ],
                  ),
                );
              }

              // Show empty state
              if (areaController.showEmptyState) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No areas available',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              // Show filtered areas
              final areas = areaController.filteredAreas;

              if (areas.isEmpty) {
                return Center(
                  child: Text(
                    'No areas match your search',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                );
              }

              return ListView.builder(
                itemCount: areas.length,
                itemBuilder: (context, index) {
                  final area = areas[index];
                  return _buildAreaTile(area, areaController);
                },
              );
            }),
          ),

          // Confirm Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() => CustomButton(
                  text: areaController.hasSelectedArea
                      ? 'Continue with ${areaController.selectedAreaName}'
                      : 'Select an Area',
                  onPressed: areaController.hasSelectedArea
                      ? () => controller.confirmLocation()
                      : null,
                  width: double.infinity,
                  icon: Icons.check,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaTile(AreaModel area, AreaController areaController) {
    return Obx(() {
      final isSelected =
          areaController.selectedArea.value?.areaId == area.areaId;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: Colors.grey[300]!),
        ),
        child: RadioListTile<String>(
          title: Text(
            area.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            'PIN: ${area.pin} • Delivery: ₹${area.charge}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          value: area.areaId,
          groupValue: areaController.selectedArea.value?.areaId,
          onChanged: (value) {
            areaController.selectArea(area);
          },
          activeColor: AppColors.primary,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
      );
    });
  }
}
