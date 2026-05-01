import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/verify_email.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/widgets/termsandconditions.dart';
import 'package:iam_ecomm/features/personalization/screens/address/add_new_address.dart';
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
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await ApiMiddleware.auth.signup(
        email: _emailController.text.trim(),
        mobileNo: _phoneController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      /// -------- ADDED: Handle API response properly --------
      if (res.success) {
        /// Save token if returned by API
        if (res.data?.token != null &&
            res.data!.token!.accessToken.isNotEmpty) {
          await ApiMiddleware.setToken(res.data!.token!.accessToken);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res.message.isNotEmpty
                  ? res.message
                  : "Account created successfully",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green[300],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            duration: const Duration(seconds: 3),
          ),
        );

        final firstName = _firstNameController.text.trim();
        final lastName = _lastNameController.text.trim();
        final fullName = '$firstName $lastName'.trim();

        // Route brand-new users to their first address setup and keep
        // recipient name aligned with the account name from signup.
        await Get.to(
          () => AddNewAddressScreen(
            prefilledRecipientName: fullName,
            lockRecipientName: true,
          ),
        );
        if (!mounted) return;

        /// Navigate to verify email
        Get.to(() => VerifyEmailScreen(email: _emailController.text.trim()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res.message.isNotEmpty
                  ? res.message
                  : "Unable to create account",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red[300],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      /// -----------------------------------------------------
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Server error. Please try again later.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[300],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                      (v == null || v.isEmpty) ? 'Required Field*' : null,
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
                      (v == null || v.isEmpty) ? 'Required Field*' : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: IAMSizes.spaceBtwInputFields),

          TextFormField(
            controller: _emailController,
            expands: false,
            decoration: const InputDecoration(
              labelText: IAMTexts.email,
              prefixIcon: Icon(Iconsax.direct),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required Field*';
              final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!regex.hasMatch(v)) return 'Invalid email';
              return null;
            },
          ),

          const SizedBox(height: IAMSizes.spaceBtwInputFields),

          TextFormField(
            controller: _phoneController,
            expands: false,
            decoration: const InputDecoration(
              labelText: IAMTexts.phoneNo,
              prefixIcon: Icon(Iconsax.call),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required Field*';
              final regex = RegExp(r'^[0-9]+$');
              if (!regex.hasMatch(v)) return 'Invalid phone number';
              return null;
            },
          ),

          const SizedBox(height: IAMSizes.spaceBtwInputFields),

          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            obscuringCharacter: '•',
            decoration: InputDecoration(
              prefixIcon: const Icon(Iconsax.password_check),
              labelText: IAMTexts.password,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Iconsax.eye_slash : Iconsax.eye),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Required Field*' : null,
          ),

          const SizedBox(height: IAMSizes.spaceBtwSections),

          const IAMTermsAndConditions(),

          const SizedBox(height: IAMSizes.spaceBtwSections),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(IAMTexts.createAccount),
            ),
          ),
        ],
      ),
    );
  }
}
