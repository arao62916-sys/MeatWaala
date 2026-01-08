/// Global application state for managing critical errors
///
/// This class maintains a singleton state to prevent duplicate error handling
/// when critical errors (offline, timeout, server errors) occur.
class AppState {
  // Private constructor for singleton
  AppState._();
  static final AppState _instance = AppState._();
  static AppState get instance => _instance;

  /// Flag indicating if a critical error has occurred
  /// When true, prevents:
  /// - Duplicate error screens
  /// - Duplicate snackbars
  /// - Further API calls
  /// - Navigation to main screens
  bool hasCriticalError = false;

  /// Reset the critical error flag
  /// Call this when:
  /// - User manually retries
  /// - Internet connection is restored
  /// - App is restarted
  void resetCriticalError() {
    hasCriticalError = false;
  }

  /// Set critical error flag
  /// Returns true if this is the first time error is set
  /// Returns false if error was already set (prevents duplicates)
  bool setCriticalError() {
    if (hasCriticalError) {
      return false; // Already set, prevent duplicate handling
    }
    hasCriticalError = true;
    return true; // First time, allow handling
  }
}
