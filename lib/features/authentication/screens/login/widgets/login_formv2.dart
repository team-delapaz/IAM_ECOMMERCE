import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/signup.dart';

class LoginScreenV2 extends StatefulWidget {
  const LoginScreenV2({super.key});

  @override
  State<LoginScreenV2> createState() => _LoginScreenV2State();
}

class _LoginScreenV2State extends State<LoginScreenV2> {
  bool isLogin = true;
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,

      body: Stack(
        children: [
          /// ===== BACK BUTTON =====
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Iconsax.arrow_left, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),

          /// ===== WHITE ARCHED CONTAINER =====
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(IAMSizes.defaultSpace),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),

              child: Column(
                children: [
                  /// ===== TOGGLE BUTTON =====
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => isLogin = true);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isLogin
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Center(child: Text("Login")),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => isLogin = false);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isLogin
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Center(child: Text("Register")),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: IAMSizes.spaceBtwSections),

                  /// ===== FORM SECTION =====
                  if (isLogin) ...[
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: IAMTexts.email,
                        prefixIcon: Icon(Iconsax.direct_right),
                      ),
                    ),
                    const SizedBox(height: IAMSizes.spaceBtwInputFields),

                    TextFormField(
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: IAMTexts.password,
                        prefixIcon: const Icon(Iconsax.password_check),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ] else ...[
                    /// REGISTER PLACEHOLDER
                    const Text("Register Form Goes Here"),
                  ],

                  const SizedBox(height: IAMSizes.spaceBtwSections),

                  /// ===== BUTTON =====
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        isLogin ? IAMTexts.signIn : IAMTexts.createAccount,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
