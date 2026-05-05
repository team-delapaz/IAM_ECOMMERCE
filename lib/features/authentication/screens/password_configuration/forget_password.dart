import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/screens/password_configuration/otp_reset_code.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final emailAddress = _emailController.text.trim();

    setState(() => _isSubmitting = true);
    final res = await ApiMiddleware.auth.forgotPassword(emailAddress);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.message.isNotEmpty
                ? res.message
                : 'Unable to send reset code right now.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res.message.isNotEmpty
              ? res.message
              : 'Reset code sent. Please check your email.',
        ),
      ),
    );

    Get.to(() => OtpResetCodeScreen(emailAddress: emailAddress));
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: dark ? IAMColors.white : IAMColors.black,
        iconTheme: IconThemeData(
          color: dark ? IAMColors.white : IAMColors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(IAMSizes.defaultSpace),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Headings
              Text(
                IAMTexts.forgetPasswordTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),
              Text(
                IAMTexts.forgetPasswordSubTitle,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections * 2),

              //Text Fields
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: IAMTexts.emailAddress,
                  prefixIcon: Icon(Iconsax.direct_right),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return 'Email is required.';
                  final regex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!regex.hasMatch(email)) return 'Enter a valid email.';
                  return null;
                },
                onFieldSubmitted: (_) => _isSubmitting ? null : _submit(),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              //Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(IAMTexts.submit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
