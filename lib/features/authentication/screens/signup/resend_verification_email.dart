import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/verify_email.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class ResendVerificationEmailScreen extends StatefulWidget {
  const ResendVerificationEmailScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ResendVerificationEmailScreen> createState() =>
      _ResendVerificationEmailScreenState();
}

class _ResendVerificationEmailScreenState
    extends State<ResendVerificationEmailScreen> {
  late final TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = _emailController.text.trim();
    setState(() => _isSending = true);
    final res = await ApiMiddleware.auth.resendVerificationCode(email);
    if (!mounted) return;
    setState(() => _isSending = false);

    if (!res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.message.isNotEmpty
                ? res.message
                : 'Unable to send verification code.',
          ),
        ),
      );
      return;
    }

    final msg = res.data?.message.isNotEmpty == true
        ? res.data!.message
        : 'Verification code sent to your email.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

    Get.to(() => VerifyEmailScreen(email: email));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(IAMSizes.defaultSpace),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your email to resend the verification code.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Email is required.';
                  final regex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!regex.hasMatch(value)) return 'Enter a valid email.';
                  return null;
                },
                onFieldSubmitted: (_) => _isSending ? null : _sendCode(),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
              ElevatedButton(
                onPressed: _isSending ? null : _sendCode,
                child: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Verification Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
