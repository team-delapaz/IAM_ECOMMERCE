import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/verify_email.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/widgets/termsandconditions.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iconsax/iconsax.dart';

class IAMSignupForm extends StatefulWidget {
  const IAMSignupForm({super.key});

  @override
  State<IAMSignupForm> createState() => _IAMSignupFormState();
}

class _IAMSignupFormState extends State<IAMSignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final res = await ApiMiddleware.auth.signup(
      email: _emailController.text.trim(),
      mobileNo: _phoneController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (!res.success) {
      final msg =
          res.message.isNotEmpty ? res.message : 'Signup failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signup successful. Please verify your email.')),
    );
    Get.to(() => const VerifyEmailScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  expands: false,
                  decoration: const InputDecoration(
                    labelText: IAMTexts.firstName,
                    prefixIcon: Icon(Iconsax.user),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(width: IAMSizes.spaceBtwInputFields),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  expands: false,
                  decoration: const InputDecoration(
                    labelText: IAMTexts.lastName,
                    prefixIcon: Icon(Iconsax.user),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: IAMSizes.spaceBtwInputFields),

          //Username (optional / display only for now)
          TextFormField(
            expands: false,
            decoration: const InputDecoration(
              labelText: IAMTexts.username,
              prefixIcon: Icon(Iconsax.user_edit),
            ),
          ),
          const SizedBox(height: IAMSizes.spaceBtwInputFields),
          //Email
          TextFormField(
            controller: _emailController,
            expands: false,
            decoration: const InputDecoration(
              labelText: IAMTexts.email,
              prefixIcon: Icon(Iconsax.direct),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: IAMSizes.spaceBtwInputFields),
          //Phone number
          TextFormField(
            controller: _phoneController,
            expands: false,
            decoration: const InputDecoration(
              labelText: IAMTexts.phoneNo,
              prefixIcon: Icon(Iconsax.call),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: IAMSizes.spaceBtwInputFields),
          //Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            expands: false,
            decoration: InputDecoration(
              labelText: IAMTexts.password,
              prefixIcon: const Icon(Iconsax.password_check),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: IAMSizes.spaceBtwSections),
          //Terms and Conditions Checkbox
          const IAMTermsAndConditions(),
          const SizedBox(height: IAMSizes.spaceBtwSections),
          //Sign up button
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
                  : const Text(IAMTexts.createAccount),
            ),
          ),
        ],
      ),
    );
  }
}
