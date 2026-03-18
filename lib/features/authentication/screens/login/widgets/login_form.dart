import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/signup.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/navigation_menu.dart' show NavigationController;
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
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
    });

    final res = await ApiMiddleware.auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (!res.success || res.data?.token == null) {
      final msg =
          res.message.isNotEmpty ? res.message : 'Invalid credentials.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $msg')),
      );
      return;
    }

    await ApiMiddleware.setToken(res.data!.token!.accessToken);
    AuthController.instance.login();

    final successMsg =
        res.message.isNotEmpty ? res.message : 'You are now signed in.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successMsg)),
    );

    if (Get.isRegistered<NavigationController>()) {
      final nav = Get.find<NavigationController>();
      nav.selectedIndex.value = 0;
    } else {
      Get.offAll(() => const NavigationMenu());
    }
  }

  @override
  Widget build(BuildContext context) {
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
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: IAMTexts.email,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required Field*';
                if (_emailError != null) return _emailError;
                return null;
              },
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: IAMSizes.spaceBtwInputFields),
            //password
            TextFormField(
              onChanged: (_) {
                if (_emailError != null) {
                  setState(() => _emailError = null);
                }
              },
              controller: _passwordController,
              obscureText: _obscurePassword,
              obscuringCharacter: '•', //Hide Password
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.password_check),
                labelText: IAMTexts.password,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Iconsax.eye_slash : Iconsax.eye),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required Field*';
                if (_passwordError != null) return _passwordError;
                return null;
              },
              textInputAction: TextInputAction.done,

              onFieldSubmitted: (_) => _submit(),
            ),

            const SizedBox(height: IAMSizes.spaceBtwInputFields / 2),

            // Remember me and forget password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //remeber me
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (value) {}),
                    const Text(IAMTexts.rememberMe),
                  ],
                ),

                //forgot password
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
                onPressed:
                    _loading ? null : () => Get.to(() => const SignupScreen()),
                child: Text(IAMTexts.createAccount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
