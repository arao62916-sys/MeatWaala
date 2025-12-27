# Quick Reference Guide - MeatWaala UI Theme

## 🎨 Colors (AppColors)

### Primary

```dart
AppColors.primary          // #D32F2F (Red)
AppColors.primaryDark      // #B71C1C
AppColors.primaryLight     // #EF5350
```

### Secondary

```dart
AppColors.secondary        // #212121 (Dark Grey)
AppColors.secondaryLight   // #424242
```

### Background

```dart
AppColors.background       // #FAFAFA
AppColors.surface          // #FFFFFF
AppColors.cardBackground   // #FFFFFF
```

### Text

```dart
AppColors.textPrimary      // #212121
AppColors.textSecondary    // #757575
AppColors.textHint         // #BDBDBD
AppColors.textWhite        // #FFFFFF
```

### Status

```dart
AppColors.success          // #4CAF50
AppColors.warning          // #FFC107
AppColors.error            // #F44336
AppColors.info             // #2196F3
```

### Borders

```dart
AppColors.border           // #E0E0E0
AppColors.divider          // #EEEEEE
```

---

## 📝 Typography

### Headlines

```dart
Theme.of(context).textTheme.displayLarge    // 32px, Bold
Theme.of(context).textTheme.displayMedium   // 28px, Bold
Theme.of(context).textTheme.displaySmall    // 24px, Bold
Theme.of(context).textTheme.headlineMedium  // 20px, SemiBold
Theme.of(context).textTheme.headlineSmall   // 18px, SemiBold
```

### Titles & Body

```dart
Theme.of(context).textTheme.titleLarge   // 16px, SemiBold
Theme.of(context).textTheme.titleMedium  // 14px, Medium
Theme.of(context).textTheme.bodyLarge    // 16px, Normal
Theme.of(context).textTheme.bodyMedium   // 14px, Normal
Theme.of(context).textTheme.bodySmall    // 12px, Normal
```

---

## 📐 Spacing System

```dart
const SizedBox(height: 4)   // XS
const SizedBox(height: 8)   // S
const SizedBox(height: 12)  // M
const SizedBox(height: 16)  // L
const SizedBox(height: 24)  // XL
const SizedBox(height: 32)  // XXL
```

---

## 🎯 Common Patterns

### AppBar Template

```dart
AppBar(
  title: const Text('Screen Title'),
  actions: const [SizedBox(width: 4)],
)
```

### Card Template

```dart
Card(
  elevation: 2,
  shadowColor: AppColors.textPrimary.withOpacity(0.1),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: // Your content
)
```

### Empty State Template

```dart
Center(
  child: Padding(
    padding: const EdgeInsets.all(32.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.your_icon,
          size: 64,
          color: AppColors.textSecondary.withOpacity(0.5),
        ),
        const SizedBox(height: 24),
        Text(
          'Main Message',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Subtitle or explanation',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    ),
  ),
)
```

### Error State Template

```dart
Center(
  child: Padding(
    padding: const EdgeInsets.all(32.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 64,
          color: AppColors.error.withOpacity(0.7),
        ),
        const SizedBox(height: 24),
        Text(
          'Error Title',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          errorMessage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: retryFunction,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    ),
  ),
)
```

### Loading State Template

```dart
const Center(
  child: CircularProgressIndicator(),
)
```

---

## 🔘 Buttons

### Primary Button

```dart
ElevatedButton(
  onPressed: () {},
  child: const Text('Button Text'),
)
```

### Secondary Button

```dart
OutlinedButton(
  onPressed: () {},
  child: const Text('Button Text'),
)
```

### Text Button

```dart
TextButton(
  onPressed: () {},
  child: const Text('Button Text'),
)
```

### Custom Button (Recommended)

```dart
CustomButton(
  text: 'Button Text',
  onPressed: () {},
  isLoading: false,
  icon: Icons.icon_name, // Optional
  width: double.infinity, // Optional
)
```

---

## 📄 Grid Layouts

### 2-Column Product Grid

```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.68,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
  ),
  itemBuilder: (context, index) => // Card widget
)
```

### 2-Column Category Grid

```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.85,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
  ),
  itemBuilder: (context, index) => // Category card
)
```

---

## 🖼️ Images

### Network Image with Placeholder

```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  fit: BoxFit.cover,
  placeholder: (context, url) => Container(
    color: AppColors.border.withOpacity(0.3),
    child: const Center(
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  ),
  errorWidget: (context, url, error) => Container(
    color: AppColors.border.withOpacity(0.3),
    child: const Icon(
      Icons.image_not_supported_outlined,
      size: 40,
      color: AppColors.textSecondary,
    ),
  ),
)
```

---

## 📦 Text Overflow Prevention

### Using maxLines and overflow

```dart
Text(
  'Long text that might overflow',
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
  style: Theme.of(context).textTheme.bodyMedium,
)
```

### Using Flexible/Expanded

```dart
Row(
  children: [
    Icon(Icons.icon),
    const SizedBox(width: 8),
    Flexible(
      child: Text(
        'Text that might be long',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
)
```

---

## 🎭 Badges

### Discount Badge

```dart
Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  ),
  decoration: BoxDecoration(
    color: AppColors.success,
    borderRadius: BorderRadius.circular(8),
  ),
  child: const Text(
    '20% OFF',
    style: TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

### Status Badge

```dart
Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  ),
  decoration: BoxDecoration(
    color: statusColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(6),
  ),
  child: Text(
    'Status',
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: statusColor,
    ),
  ),
)
```

---

## 📱 Responsive Patterns

### MediaQuery Width

```dart
final width = MediaQuery.of(context).size.width;
final isSmallScreen = width < 360;
final isLargeScreen = width > 600;
```

### Adaptive Column Count

```dart
final columnCount = width > 600 ? 3 : 2;
```

---

## ⚡ Best Practices

1. **Always use theme colors** - Never hardcode colors
2. **Use const constructors** - When possible for performance
3. **Add keys to widgets** - For better rebuilds
4. **Handle all states** - Loading, Success, Error, Empty
5. **Prevent overflow** - Use maxLines, Flexible, Expanded
6. **Test responsive** - Small and large screens
7. **Use semantic naming** - Clear variable and function names
8. **Follow spacing system** - 8, 12, 16, 24, 32
9. **Maintain consistency** - Same patterns across screens
10. **Format code** - Use `dart format` before commit

---

## 🔍 Common Issues & Solutions

### Issue: Text overflow

**Solution:** Add `maxLines` and `overflow: TextOverflow.ellipsis`

### Issue: RenderFlex overflow

**Solution:** Wrap in `Flexible` or `Expanded`, or use `SingleChildScrollView`

### Issue: Image not loading

**Solution:** Use `CachedNetworkImage` with proper error widget

### Issue: Button too small on mobile

**Solution:** Minimum height 48px, use `SizedBox` wrapper

### Issue: Inconsistent spacing

**Solution:** Follow spacing system (8, 12, 16, 24, 32)

### Issue: Hard to read text

**Solution:** Check contrast ratio, use theme text styles

---

## 📚 Resources

- [Material Design 3](https://m3.material.io/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [WCAG Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Google Fonts](https://fonts.google.com/)

---

**Last Updated:** December 27, 2025  
**Version:** 1.0.0  
**Maintainer:** UI/UX Team
