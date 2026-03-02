import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/signup.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iconsax/iconsax.dart';

class IAMLoginForm extends StatefulWidget {
  const IAMLoginForm({super.key});

  @override
  State<IAMLoginForm> createState() => _IAMLoginFormState();
}

class _IAMLoginFormState extends State<IAMLoginForm> {
  bool obscurePassword = true;
  bool rememberMe = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: IAMSizes.spaceBtwSections,
        ),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.sms),
                labelText: IAMTexts.email,
              ),
            ),

            const SizedBox(height: IAMSizes.spaceBtwInputFields),

            TextFormField(
              obscureText: obscurePassword,
              obscuringCharacter: '•',
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.password_check),
                labelText: IAMTexts.password,
                suffixIcon: IconButton(
                  icon: Icon(obscurePassword ? Iconsax.eye_slash : Iconsax.eye),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: IAMSizes.spaceBtwInputFields / 2),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
                      },
                    ),
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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.to(() => const NavigationMenu()),
                child: Text(IAMTexts.signIn),
              ),
            ),

            const SizedBox(height: IAMSizes.spaceBtwItems),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.to(() => const SignupScreen()),
                child: Text(IAMTexts.createAccount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
