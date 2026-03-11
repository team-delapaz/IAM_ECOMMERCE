import 'package:get/get.dart';

/// Mock auth controller (for UI/demo purposes).
///
/// - Starts logged out
/// - Call [login] to mark as logged in
/// - Call [logout] to mark as logged out
class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();

  final RxBool isLoggedIn = false.obs;

  void login() => isLoggedIn.value = true;

  void logout() => isLoggedIn.value = false;
}

