import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class OtpResetCodeScreen extends StatefulWidget {
  const OtpResetCodeScreen({super.key, required this.emailAddress});

  final String emailAddress;

  @override
  State<OtpResetCodeScreen> createState() => _OtpResetCodeScreenState();
}

class _OtpResetCodeScreenState extends State<OtpResetCodeScreen> {
  final _pinControllers = List.generate(6, (_) => TextEditingController());
  final _pinFocusNodes = List.generate(6, (_) => FocusNode());
  bool _isValidating = false;
  bool _isResending = false;
  String? _pinError;

  @override
  void dispose() {
    for (final c in _pinControllers) {
      c.dispose();
    }
    for (final f in _pinFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _pinValue => _pinControllers.map((c) => c.text).join();

  void _clearPinError() {
    if (_pinError == null) return;
    setState(() => _pinError = null);
  }

  void _focusIndex(int index) {
    if (index < 0 || index >= _pinFocusNodes.length) return;
    _pinFocusNodes[index].requestFocus();
  }

  Future<void> _validateCode() async {
    final resetCode = _pinValue.trim();
    if (resetCode.length != 6) {
      setState(() => _pinError = 'Enter the 6-digit reset code.');
      return;
    }
    _clearPinError();

    setState(() => _isValidating = true);
    final res = await ApiMiddleware.auth.validateResetCode(
      emailAddress: widget.emailAddress,
      resetCode: resetCode,
    );
    if (!mounted) return;
    setState(() => _isValidating = false);

    final isValid = res.success && (res.data?.isValid ?? false);
    if (!isValid) {
      setState(
        () => _pinError = res.message.isNotEmpty
            ? res.message
            : 'Invalid or expired reset code. Please try again.',
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reset code verified.')),
    );

    Get.to(
      () => ResetPassword(
        emailAddress: widget.emailAddress,
        resetCode: resetCode,
      ),
    );
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);
    final res = await ApiMiddleware.auth.forgotPassword(widget.emailAddress);
    if (!mounted) return;
    setState(() => _isResending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res.success
              ? (res.message.isNotEmpty
                    ? res.message
                    : 'A new reset code was sent to your email.')
              : (res.message.isNotEmpty
                    ? res.message
                    : 'Unable to resend reset code right now.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(IAMSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Reset Code',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: IAMSizes.spaceBtwItems),
            Text(
              'Enter the OTP reset code sent to ${widget.emailAddress}.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: IAMSizes.spaceBtwSections * 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: SizedBox(
                    width: 46,
                    child: TextField(
                      controller: _pinControllers[i],
                      focusNode: _pinFocusNodes[i],
                      enabled: !_isValidating,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        errorText: null,
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _pinError == null
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _pinError == null
                                ? Theme.of(context).dividerColor
                                : Theme.of(context).colorScheme.error,
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (v) {
                        _clearPinError();
                        if (v.isNotEmpty) {
                          if (i < 5) {
                            _focusIndex(i + 1);
                          } else {
                            FocusScope.of(context).unfocus();
                            _validateCode();
                          }
                        } else {
                          if (i > 0) _focusIndex(i - 1);
                        }
                      },
                      onSubmitted: (_) => _isValidating ? null : _validateCode(),
                    ),
                  ),
                );
              }),
            ),
            if (_pinError != null) ...[
              const SizedBox(height: 8),
              Text(
                _pinError!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
            const SizedBox(height: IAMSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValidating ? null : _validateCode,
                child: _isValidating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify Code'),
              ),
            ),
            const SizedBox(height: IAMSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isResending ? null : _resendCode,
                child: _isResending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Resend Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
