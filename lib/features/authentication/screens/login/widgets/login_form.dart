import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/resend_verification_email.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/signup.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iam_ecomm/utils/local_storage/storage_utility.dart';
import 'package:iconsax/iconsax.dart';

class IAMLoginForm extends StatefulWidget {
  const IAMLoginForm({super.key});

  @override
  State<IAMLoginForm> createState() => _IAMLoginFormState();
}

class _IAMLoginFormState extends State<IAMLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _emailError;
  String? _passwordError;
  bool _showVerifyEmailAction = false;

  bool _isEmailVerificationError(String message) {
    final m = message.toLowerCase();
    return m.contains('verify') && m.contains('email');
  }

  Future<void> _mergeGuestCartIntoServer() async {
    final storage = IAMLocalStorage();
    final raw = storage.readData<List>('guest_cart') ?? [];
    if (raw.isEmpty) return;

    // Merge duplicate productCode entries so we can reduce API calls.
    final Map<String, int> qtyByCode = {};
    for (final entry in raw) {
      final map = Map<String, dynamic>.from(entry as Map);
      final code = map['productCode'] as String? ?? '';
      if (code.isEmpty) continue;

      final qtyValue = map['qty'];
      final qty = qtyValue is int
          ? qtyValue
          : qtyValue is num
          ? qtyValue.toInt()
          : int.tryParse(qtyValue?.toString() ?? '') ?? 0;
      if (qty <= 0) continue;

      qtyByCode[code] = (qtyByCode[code] ?? 0) + qty;
    }

    if (qtyByCode.isEmpty) return;

    bool anySuccess = false;
    for (final e in qtyByCode.entries) {
      final res = await ApiMiddleware.cart.add(
        productCode: e.key,
        qty: e.value,
      );
      anySuccess = anySuccess || res.success;
    }

    // Only clear once we know at least one cart item was added successfully.
    if (anySuccess) {
      await storage.removeData('guest_cart');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _emailError = null;
      _passwordError = null;
      _showVerifyEmailAction = false;
    });

    final res = await ApiMiddleware.auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (!res.success || res.data?.user == null) {
      final msg = res.message.isNotEmpty ? res.message : 'Invalid credentials.';
      setState(() {
        _emailError = null;
        _passwordError = msg;
        _showVerifyEmailAction = _isEmailVerificationError(msg);
      });
      return;
    }

    final accessToken = res.data?.token?.accessToken ?? '';
    if (accessToken.isNotEmpty) {
      await ApiMiddleware.setToken(accessToken);
    } else {
      await ApiMiddleware.clearToken();
    }
    final loggedInUser = res.data!.user;

    // If the user previously added items as a guest, merge those items
    // into the server cart after successful login.
    await _mergeGuestCartIntoServer();
    if (!mounted) return;

    final navController = Get.isRegistered<NavigationController>()
        ? Get.find<NavigationController>()
        : Get.put(NavigationController());
    navController.selectedIndex.value = 0;
    AuthController.instance.login(loggedInUser);

    final successMsg = res.message.isNotEmpty
        ? res.message
        : 'You are now signed in.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMsg, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[300],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );

    Get.offAll(const NavigationMenu());
  }

  @override
  Widget build(BuildContext context) {
    final hasCredentialError =
        _passwordError != null && _passwordError!.isNotEmpty;
    final errorBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(14),
    );

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: IAMSizes.spaceBtwSections,
        ),
        child: Column(
          children: [
            //email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.direct_right),
                labelText: IAMTexts.email,
                enabledBorder: hasCredentialError ? errorBorder : null,
                focusedBorder: hasCredentialError ? errorBorder : null,
              ),
              onChanged: (_) {
                if (_emailError != null || _passwordError != null) {
                  setState(() {
                    _emailError = null;
                    _passwordError = null;
                    _showVerifyEmailAction = false;
                  });
                }
              },
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required Field*';
                return null;
              },
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: IAMSizes.spaceBtwInputFields),
            //password
            TextFormField(
              onChanged: (_) {
                if (_emailError != null || _passwordError != null) {
                  setState(() {
                    _emailError = null;
                    _passwordError = null;
                    _showVerifyEmailAction = false;
                  });
                }
              },
              controller: _passwordController,
              obscureText: _obscurePassword,
              obscuringCharacter: '•', //Hide Password
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.password_check),
                labelText: IAMTexts.password,
                errorText: _passwordError,
                enabledBorder: hasCredentialError ? errorBorder : null,
                focusedBorder: hasCredentialError ? errorBorder : null,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required Field*';
                return null;
              },
              textInputAction: TextInputAction.done,

              onFieldSubmitted: (_) => _submit(),
            ),
            if (_showVerifyEmailAction) ...[
              const SizedBox(height: IAMSizes.sm),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Get.to(
                      () => ResendVerificationEmailScreen(
                        initialEmail: _emailController.text.trim(),
                      ),
                    );
                  },
                  child: const Text('Verify Email'),
                ),
              ),
            ],

            const SizedBox(height: IAMSizes.spaceBtwInputFields / 2),

            // Remember me and forget password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(value: true, onChanged: (value) {}),
                    const Text(IAMTexts.rememberMe),
                  ],
                ),
                TextButton(
                  onPressed: () => Get.to(() => const ForgetPassword()),
                  child: const Text(IAMTexts.forgetPassword),
                ),
              ],
            ),

            const SizedBox(height: IAMSizes.spaceBtwSections),

            //Sign in button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(IAMTexts.signIn),
              ),
            ),

            const SizedBox(height: IAMSizes.spaceBtwItems),

            //Create Account Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _loading
                    ? null
                    : () => Get.to(() => const SignupScreen()),
                child: Text(IAMTexts.createAccount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
