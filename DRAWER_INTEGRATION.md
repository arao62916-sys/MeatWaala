# Side Navigation Drawer Integration

## Overview
The `AppDrawer` is a modern, responsive side navigation component built with Flutter and GetX. It features a user profile header, configurable menu items with active state highlighting, and smooth animations.

## Features
- **User Header**: Displays circular profile image, name, and email with a gradient background.
- **Navigation Menu**: Scrollable list of menu items with icons and badges.
- **Active State**: Automatically highlights the current route.
- **Responsive**: Works on mobile and tablet.
- **Customizable**: Menu items defined in `DrawerMenuItem` model.
- **State Management**: Uses `AppDrawerController` for logic.

## Usage

### 1. Basic Usage
Add the `AppDrawer` to your `Scaffold`'s `drawer` property:

```dart
import 'package:meatwaala_app/core/widgets/drawer/app_drawer.dart';

Scaffold(
  drawer: const AppDrawer(),
  appBar: AppBar(
    // The hamburger menu appears automatically
  ),
  body: YourBodyWidget(),
);
```

### 2. Customizing Menu Items
Edit the `menuItems` list in `lib/core/widgets/drawer/app_drawer.dart`:

```dart
final List<DrawerMenuItem> menuItems = [
  DrawerMenuItem(
    title: 'New Item',
    icon: Icons.star,
    route: '/new-route',
    showBadge: true,
    badgeCount: 5,
  ),
  // ...
];
```

### 3. Controller Logic
`AppDrawerController` handles:
- User data loading (currently mock data)
- Route tracking
- Logout logic

To update the user profile image dynamically:
```dart
final drawerController = Get.find<AppDrawerController>();
drawerController.updateProfileImage('https://example.com/image.jpg');
```

## Files
- `lib/core/widgets/drawer/app_drawer.dart`: Main widget.
- `lib/core/widgets/drawer/app_drawer_controller.dart`: Logic and state.
- `lib/core/widgets/drawer/drawer_menu_item.dart`: Menu item model.

## Dependencies
- `get`: For state management and navigation.
- `cached_network_image`: For profile images.
- `meatwaala_app/core/theme/app_colors.dart`: For styling.

## Notes
- The drawer automatically updates the active route highlight when opened.
- Ensure routes used in `menuItems` exist in `AppRoutes`.
