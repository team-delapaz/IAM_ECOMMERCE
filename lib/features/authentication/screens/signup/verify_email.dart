import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/common/widgets/success_screen/success_screen.dart';
import 'package:iam_ecomm/features/authentication/screens/login/login.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    required this.email,
    this.referralName,
  });

  final String email;
  final String? referralName;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _pinControllers = List.generate(6, (_) => TextEditingController());
  final _pinFocusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  bool _isResending = false;
  String? _pinError;

  double _clampDouble(double v, double min, double max) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }

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

  Future<void> _verifyCode() async {
    final code = _pinValue.trim();
    if (code.length != 6) {
      setState(() => _pinError = 'Enter the 6-digit code.');
      return;
    }
    _clearPinError();

    setState(() => _isVerifying = true);
    final res = await ApiMiddleware.auth.verifyCode(
      email: widget.email,
      code: code,
    );
    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (res.success && res.data?.isVerified == true) {
      final referralName = widget.referralName?.trim() ?? '';
      final baseSubtitleStyle = Theme.of(context).textTheme.labelMedium;
      final emphasisSubtitleStyle =
          Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              );

      Get.to(
        () => SuccessScreen(
          image: IAMImages.successRegistration,
          title: IAMTexts.yourAccountCreatedTitle,
          subTitle: IAMTexts.yourAccountCreatedSubTitle,
          subTitleWidget: referralName.isNotEmpty
              ? RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${IAMTexts.yourAccountCreatedSubTitle}\n\n',
                        style: baseSubtitleStyle,
                      ),
                      const TextSpan(
                        text: 'Referral: ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: referralName,
                        style: emphasisSubtitleStyle,
                      ),
                    ],
                    style: baseSubtitleStyle,
                  ),
                )
              : null,
          onPressed: () => Get.to(() => const LoginScreen()),
        ),
      );
      return;
    }

    setState(() => _pinError =
        res.message.isNotEmpty ? res.message : 'Incorrect verification code.');
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);
    final res = await ApiMiddleware.auth.resendVerificationCode(widget.email);
    if (!mounted) return;
    setState(() => _isResending = false);

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.data?.message.isNotEmpty == true ? res.data!.message : IAMTexts.resendEmail),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res.message.isNotEmpty ? res.message : 'Unable to resend code.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Get.offAll(() => const LoginScreen()),
            icon: const Icon(CupertinoIcons.clear),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            children: [
              //IMAGE
              Image(
                image: AssetImage(IAMImages.emailSent),
                width: IAMHelperFunctions.screenWidth() * 0.6,
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // TITLE AND SUBTITLE
              Text(
                IAMTexts.confirmEmailTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),
              Text(
                widget.email,
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              if (widget.referralName != null &&
                  widget.referralName!.trim().isNotEmpty) ...[
                const SizedBox(height: IAMSizes.spaceBtwItems / 2),
                Text(
                  'Referral: ${widget.referralName!}',
                  style: Theme.of(context).textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: IAMSizes.spaceBtwItems),
              Text(
                IAMTexts.confirmEmailSubTitle,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Verification code
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  IAMTexts.verificationCode,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems / 2),
              LayoutBuilder(
                builder: (context, constraints) {
                  const digits = 6;
                  const gap = 12.0; // space between boxes (matches previous 6+6 padding)
                  const maxBoxWidth = 46.0;
                  const minBoxWidth = 32.0;
                  final available = constraints.maxWidth;
                  final boxWidth = _clampDouble(
                    (available - (gap * (digits - 1))) / digits,
                    minBoxWidth,
                    maxBoxWidth,
                  );

                  return Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(digits, (i) {
                        return Padding(
                          padding:
                              EdgeInsets.only(right: i == digits - 1 ? 0 : gap),
                          child: SizedBox(
                            width: boxWidth,
                            child: TextField(
                              controller: _pinControllers[i],
                              focusNode: _pinFocusNodes[i],
                              enabled: !_isVerifying,
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
                                    _verifyCode();
                                  }
                                } else {
                                  if (i > 0) _focusIndex(i - 1);
                                }
                              },
                              onSubmitted: (_) =>
                                  _isVerifying ? null : _verifyCode(),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
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
              //BUTTONS
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyCode,
                  child: _isVerifying
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(IAMTexts.tContinue),
                ),
              ),

              const SizedBox(height: IAMSizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isResending ? null : _resendCode,
                  child: const Text(IAMTexts.resendEmail),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
