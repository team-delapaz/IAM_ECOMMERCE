import 'package:get/get.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';

/// Mock auth controller (for UI/demo purposes).
///
/// - Starts logged out
/// - Call [login] to mark as logged in
/// - Call [logout] to mark as logged out
class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();

  final RxBool isLoggedIn = false.obs;
  final Rx<UserInfo?> user = Rx<UserInfo?>(null);

  bool get isGuest {
    final id = user.value?.idno ?? '';
    if (id.isEmpty) return false;
    return id.toUpperCase().startsWith('NON');
  }

  bool get isMemberAccount {
    final id = user.value?.idno ?? '';
    if (id.isEmpty) return false;
    if (isGuest) return false;
    return RegExp(r'^\d{8}$').hasMatch(id);
  }

  bool get isMember {
    final u = user.value;
    if (u == null) return false;
    if (isGuest) return false;
    if (u.isMember) return true;
    return isMemberAccount;
  }

  void login(UserInfo? userInfo) {
    isLoggedIn.value = true;
    user.value = userInfo;
  }

  void logout() {
    isLoggedIn.value = false;
    user.value = null;
  }
}
