# Quick Reference - Navigation Flow

## 🎯 User Journey Flows

### First-Time User

```
Splash (2s) → Onboarding (3 pages) → Location → Signup → Login → Home
```

### Returning User (Logged In)

```
Splash (2s) → Home
```

### Returning User (Not Logged In + Has Area)

```
Splash (2s) → Login
```

### Returning User (Not Logged In + No Area)

```
Splash (2s) → Location → Login
```

---

## 🔑 Storage Keys

| Key                  | Type   | Default | Purpose                           |
| -------------------- | ------ | ------- | --------------------------------- |
| `is_first_time`      | bool   | `true`  | Track if user has seen onboarding |
| `is_logged_in`       | bool   | `false` | Track authentication status       |
| `selected_area_id`   | String | `null`  | Store selected delivery area ID   |
| `selected_area_name` | String | `null`  | Store selected delivery area name |

---

## 📱 Key Methods

### Check First Launch

```dart
StorageService().isFirstTime()
// Returns: true on first launch, false after onboarding
```

### Mark Onboarding Complete

```dart
StorageService().setFirstTime(false)
// Sets flag to prevent onboarding from showing again
```

### Check Login Status

```dart
StorageService().isLoggedIn()
// Returns: true if user has valid token, false otherwise
```

### Check Area Selection

```dart
StorageService().hasSelectedArea()
// Returns: true if area is selected, false otherwise
```

---

## 🔄 Navigation Logic (Splash Controller)

```dart
if (isFirstTime) {
    → Onboarding
}
else if (isLoggedIn) {
    → Main App
}
else if (hasSelectedArea) {
    → Login
}
else {
    → Location
}
```

---

## 🛠️ Testing Commands

### Clear App Data (Simulate Fresh Install)

```dart
// In debug console
StorageService().clearAll();
// Then restart app
```

### Debug Storage State

```dart
StorageService().debugPrintStorage();
```

### Check Individual Flags

```dart
print('First Time: ${StorageService().isFirstTime()}');
print('Logged In: ${StorageService().isLoggedIn()}');
print('Has Area: ${StorageService().hasSelectedArea()}');
```

---

## 📍 Important Files

| File                         | Purpose                        |
| ---------------------------- | ------------------------------ |
| `splash_controller.dart`     | Navigation decision logic      |
| `onboarding_controller.dart` | Onboarding flow + flag setting |
| `location_controller.dart`   | Location → Signup navigation   |
| `storage_service.dart`       | Persistent storage management  |

---

## ⚠️ Common Issues & Solutions

### Issue: Stuck on Splash

**Solution:** Check if `GetStorage.init()` is called in `main.dart` before app starts

### Issue: Onboarding Shows Every Time

**Solution:** Verify `setFirstTime(false)` is called in `_completeOnboarding()`

### Issue: Wrong Screen After Login

**Solution:** Check if all user data is saved correctly after login

### Issue: Back Button Shows Previous Screens

**Solution:** Ensure using `Get.offAllNamed()` instead of `Get.toNamed()`

---

## 🎨 Onboarding UI Elements

- **Skip Button**: Top-right corner (all pages)
- **Page Indicator**: Bottom center (worm effect, red primary color)
- **Next/Get Started Button**: Bottom (full width)
  - Pages 1-2: Shows "Next"
  - Page 3: Shows "Get Started"

---

## ✅ Implementation Checklist

- [x] First-time user sees onboarding
- [x] Onboarding completion sets `isFirstTime = false`
- [x] Onboarding navigates to Location screen
- [x] Location confirms and saves area to storage
- [x] Location navigates to Signup
- [x] Returning logged-in users skip to Main App
- [x] Returning non-logged users with area go to Login
- [x] Returning non-logged users without area go to Location
- [x] No navigation stack issues
- [x] No compile errors
- [x] Clean, production-ready code

---

**Last Updated:** December 27, 2025  
**Status:** Production Ready ✅
