import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/screens/password_configuration/reset_password_success.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iconsax/iconsax.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({
    super.key,
    required this.emailAddress,
    required this.resetCode,
  });

  final String emailAddress;
  final String resetCode;

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<bool> _askForConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Confirm Password Reset'),
          content: const Text(
            'Are you sure you want to reset your password using these credentials?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _submitResetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final confirmed = await _askForConfirmation();
    if (!confirmed || !mounted) return;

    final newPassword = _newPasswordController.text;

    setState(() => _isSubmitting = true);
    final res = await ApiMiddleware.auth.resetPassword(
      emailAddress: widget.emailAddress,
      resetCode: widget.resetCode,
      newPassword: newPassword,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.message.isNotEmpty
                ? res.message
                : 'Unable to reset password right now.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    Get.offAll(
      () => ResetPasswordSuccessScreen(
        message: res.message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(CupertinoIcons.clear),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset Your Password',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: IAMSizes.spaceBtwItems),
                Text(
                  'Set a new password for ${widget.emailAddress}.',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: IAMSizes.spaceBtwSections),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  obscuringCharacter: '•',
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: IAMTexts.newPassword,
                    prefixIcon: const Icon(Iconsax.password_check),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword ? Iconsax.eye_slash : Iconsax.eye,
                      ),
                      onPressed: () => setState(
                        () => _obscureNewPassword = !_obscureNewPassword,
                      ),
                    ),
                  ),
                  validator: (value) {
                    final password = value ?? '';
                    if (password.isEmpty) return 'New password is required.';
                    if (password.length < 8) {
                      return 'Password must be at least 8 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: IAMSizes.spaceBtwInputFields),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  obscuringCharacter: '•',
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Iconsax.password_check),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Iconsax.eye_slash
                            : Iconsax.eye,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                  validator: (value) {
                    final confirmPassword = value ?? '';
                    if (confirmPassword.isEmpty) {
                      return 'Confirm password is required.';
                    }
                    if (confirmPassword != _newPasswordController.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) =>
                      _isSubmitting ? null : _submitResetPassword(),
                ),
                const SizedBox(height: IAMSizes.spaceBtwSections),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitResetPassword,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(IAMTexts.done),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
