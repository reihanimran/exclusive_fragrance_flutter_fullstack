// user_manager.dart
class HandleUserLogin {
  static const String defaultEmail = "user@exclusivefragrance.com";
  static const String defaultPassword = "exclusive@fragrance";

  static bool isLoggedIn = false;
  static String? currentUser;

  static bool login(String email, String password) {
    if (email == defaultEmail && password == defaultPassword) {
      isLoggedIn = true;
      currentUser = "Reihan Imran";
      return true;
    }
    return false;
  }

  static void logout() {
    isLoggedIn = false;
    currentUser = null;
  }
}
