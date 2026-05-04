import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/formatters/formatter.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

Future<bool> showIamWalletPaySheet({
  required BuildContext context,
  required String orderRef,
  required num totalAmount,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _IamWalletPaySheet(orderRef: orderRef, totalAmount: totalAmount),
  );
  return result ?? false;
}

class _IamWalletPaySheet extends StatefulWidget {
  const _IamWalletPaySheet({required this.orderRef, required this.totalAmount});

  final String orderRef;
  final num totalAmount;

  @override
  State<_IamWalletPaySheet> createState() => _IamWalletPaySheetState();
}

class _IamWalletPaySheetState extends State<_IamWalletPaySheet> {
  WalletBalanceData? _walletData;
  bool _loadingBalance = true;
  bool _isValidating = false;
  bool _validated = false;
  String? _statusText;
  bool _statusIsError = false;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    setState(() {
      _loadingBalance = true;
      _statusText = null;
      _statusIsError = false;
    });
    final res = await ApiMiddleware.wallet.getBalance();
    if (!mounted) return;
    setState(() {
      _loadingBalance = false;
      _walletData = res.data;
      if (!res.success) {
        _statusText = res.message.isNotEmpty
            ? res.message
            : 'Unable to load wallet balance.';
        _statusIsError = true;
      }
    });
  }

  Future<bool> _validateOrder({bool showSuccessMessage = true}) async {
    // Allow validation when pay flow is already in progress.
    // The pay button sets `_isPaying` first, then calls validate.
    if (_isValidating) return false;
    setState(() {
      _isValidating = true;
      _statusText = null;
      _statusIsError = false;
    });
    final res = await ApiMiddleware.wallet.validateOrder(
      amount: widget.totalAmount,
      orderRefNo: widget.orderRef,
      remarks: 'Wallet validation',
    );
    if (!mounted) return false;
    setState(() {
      _isValidating = false;
      _validated = res.success;
      final data = res.data;
      if (res.success && data != null) {
        _walletData = WalletBalanceData(
          accountId: data.accountId,
          balance: data.remainingBalance,
        );
      }
      if (res.success && showSuccessMessage) {
        _statusText = res.message.isNotEmpty
            ? res.message
            : 'Order validated. You can proceed to payment.';
        _statusIsError = false;
      } else if (!res.success) {
        _statusText = res.message.isNotEmpty
            ? res.message
            : 'Unable to validate wallet payment.';
        _statusIsError = true;
      }
    });
    return res.success;
  }

  Future<void> _startOtpFlow() async {
    if (_isValidating || _loadingBalance) return;

    final balance = _walletData?.balance ?? 0;
    if (balance < widget.totalAmount) {
      setState(() {
        _statusText = 'Insufficient balance. Reload your IAM Wallet.';
        _statusIsError = true;
      });
      return;
    }

    var isValidated = _validated;
    if (!isValidated) {
      isValidated = await _validateOrder(showSuccessMessage: false);
      if (!mounted || !isValidated) return;
    }

    setState(() {
      _statusText = null;
      _statusIsError = false;
    });

    final sendOtpRes = await ApiMiddleware.wallet.sendOtp(
      orderRefNo: widget.orderRef,
    );
    if (!mounted) return;

    if (!sendOtpRes.success) {
      setState(() {
        _statusText = sendOtpRes.message.isNotEmpty
            ? sendOtpRes.message
            : 'Unable to send wallet OTP.';
        _statusIsError = true;
      });
      return;
    }

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _IamWalletOtpVerificationPage(
          orderRef: widget.orderRef,
          totalAmount: widget.totalAmount,
          accountId: _walletData?.accountId ?? '',
          initialBalance: _walletData?.balance ?? 0,
          initialMaskedEmail: _resolveMaskedOtpEmail(sendOtpRes.data),
          initialMessage: sendOtpRes.message.isNotEmpty
              ? sendOtpRes.message
              : 'OTP has been sent to your registered contact.',
        ),
      ),
    );

    if (!mounted) return;
    if (result == true) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _statusText =
          'OTP verification was cancelled. Complete verification to continue payment.';
      _statusIsError = true;
    });
  }

  String? _resolveMaskedOtpEmail(WalletSendOtpData? data) {
    if (data == null) return null;
    if (data.maskedEmail.trim().isNotEmpty) return data.maskedEmail.trim();
    if (data.emailAddress.trim().isEmpty) return null;
    return _maskEmail(data.emailAddress.trim());
  }

  String _maskEmail(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex <= 0 || atIndex == email.length - 1) return email;
    final local = email.substring(0, atIndex);
    final domain = email.substring(atIndex + 1);
    if (local.isEmpty) return email;
    return '${local.substring(0, 1)}***@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final surface = dark ? const Color(0xFF101217) : IAMColors.white;
    final onSurface = dark ? IAMColors.white : IAMColors.black;
    final muted = onSurface.withOpacity(dark ? 0.72 : 0.66);
    final amountText = IAMFormatter.formatCurrency(
      widget.totalAmount.toDouble(),
    );
    final balance = _walletData?.balance ?? 0;
    final balanceText = IAMFormatter.formatCurrency(balance.toDouble());
    final hasSufficientBalance =
        !_loadingBalance && balance >= widget.totalAmount;

    return FractionallySizedBox(
      heightFactor: 0.86,
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.6 : 0.2),
                blurRadius: 28,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: onSurface.withOpacity(dark ? 0.22 : 0.16),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        IAMSizes.md,
                        16,
                        4,
                        12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        (dark ? IAMColors.black : IAMColors.white)
                                            .withOpacity(dark ? 0.35 : 0.75),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: IAMColors.primary.withOpacity(
                                        dark ? 0.35 : 0.45,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Image.asset(
                                    IAMImages.walletIcon,
                                    width: 28,
                                    height: 28,
                                    fit: BoxFit.contain,
                                    semanticLabel: 'IAM Wallet',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'IAM Wallet',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: onSurface,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.2,
                                            fontSize: 22,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      widget.orderRef.isNotEmpty
                                          ? 'OR# ${widget.orderRef}'
                                          : 'Wallet checkout',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: muted,
                                            height: 1.2,
                                            fontSize: 16,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: _isValidating
                                ? null
                                : () => Navigator.of(context).pop(false),
                            icon: Icon(
                              Icons.close_rounded,
                              color: onSurface.withOpacity(0.72),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          IAMSizes.md,
                          0,
                          IAMSizes.defaultSpace,
                          IAMSizes.defaultSpace,
                        ),
                        child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: onSurface.withOpacity(
                                          dark ? 0.14 : 0.1,
                                        ),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: dark
                                            ? [
                                                IAMColors.black,
                                                IAMColors.black.withOpacity(
                                                  0.92,
                                                ),
                                              ]
                                            : [
                                                IAMColors.white,
                                                IAMColors.softGrey,
                                              ],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        IAMSizes.md,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          _WalletMetric(
                                            label: 'Wallet balance',
                                            value: _loadingBalance
                                                ? '…'
                                                : balanceText,
                                            valueColor: _loadingBalance
                                                ? muted
                                                : IAMColors.primary,
                                            dark: dark,
                                          ),
                                          if (!_loadingBalance) ...[
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(
                                                  hasSufficientBalance
                                                      ? Icons
                                                          .check_circle_rounded
                                                      : Icons.cancel_rounded,
                                                  size: 18,
                                                  color: hasSufficientBalance
                                                      ? Colors.green[400]
                                                      : Colors.red[400],
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  hasSufficientBalance
                                                      ? 'Sufficient Funds'
                                                      : 'Insufficient Funds',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                    color: hasSufficientBalance
                                                        ? Colors.green[400]
                                                        : Colors.red[400],
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.25,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          const SizedBox(height: 14),
                                          _WalletMetric(
                                            label: 'Amount due',
                                            value: amountText,
                                            valueColor: onSurface,
                                            dark: dark,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (_walletData != null) ...[
                                    const SizedBox(height: 16),
                                    IAMRoundedContainer(
                                      showBorder: true,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: IAMSizes.md,
                                        vertical: 10,
                                      ),
                                      backgroundColor: dark
                                          ? IAMColors.black.withOpacity(0.45)
                                          : IAMColors.accent.withOpacity(0.35),
                                      borderColor: IAMColors.primary
                                          .withOpacity(dark ? 0.28 : 0.22),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.badge_outlined,
                                            size: 18,
                                            color: IAMColors.primary
                                                .withOpacity(0.9),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Account ID: ${_walletData!.accountId}',
                                              maxLines: 1,
                                              softWrap: false,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge
                                                  ?.copyWith(
                                                    color: onSurface
                                                        .withOpacity(0.88),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (_statusText != null) ...[
                                    const SizedBox(height: 14),
                                    IAMRoundedContainer(
                                      backgroundColor: _statusIsError
                                          ? Colors.red.withOpacity(
                                              dark ? 0.2 : 0.1,
                                            )
                                          : Colors.green.withOpacity(
                                              dark ? 0.2 : 0.1,
                                            ),
                                      borderColor: _statusIsError
                                          ? Colors.red.withOpacity(
                                              dark ? 0.4 : 0.2,
                                            )
                                          : Colors.green.withOpacity(
                                              dark ? 0.4 : 0.2,
                                            ),
                                      showBorder: true,
                                      padding: const EdgeInsets.all(
                                        IAMSizes.md,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            _statusIsError
                                                ? Icons.error_outline_rounded
                                                : Icons
                                                      .check_circle_outline_rounded,
                                            size: 20,
                                            color: _statusIsError
                                                ? Colors.red[300]
                                                : Colors.green[300],
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _statusText!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: onSurface,
                                                    height: 1.35,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.security_rounded,
                                        size: 18,
                                        color: muted,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'For your security, this payment requires verification via OTP.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                            color: muted,
                                            height: 1.3,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 26),
                                  /*IAMRoundedContainer(
                                    showBorder: true,
                                    padding: const EdgeInsets.all(IAMSizes.md),
                                    backgroundColor: dark
                                        ? IAMColors.black.withOpacity(0.42)
                                        : IAMColors.softGrey,
                                    borderColor: onSurface.withOpacity(
                                      dark ? 0.14 : 0.08,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.sms_outlined,
                                          color: IAMColors.primary.withOpacity(
                                            0.9,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'OTP verification happens on the next page',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      color: onSurface,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'We will validate the order, send your one-time code, and let you confirm payment only after successful verification.',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: muted,
                                                      height: 1.35,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),*/
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed:
                                          (!_loadingBalance &&
                                              !_isValidating &&
                                              hasSufficientBalance)
                                          ? _startOtpFlow
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: IAMColors.primary,
                                        foregroundColor: IAMColors.white,
                                        elevation: dark ? 0 : 2,
                                        shadowColor: IAMColors.primary
                                            .withOpacity(0.45),
                                        minimumSize: const Size.fromHeight(54),
                                        disabledBackgroundColor: IAMColors.grey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: _isValidating
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                color: IAMColors.white,
                                              ),
                                            )
                                          : Row(
                                              mainAxisSize:
                                                  MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.lock_rounded,
                                                  size: 20,
                                                  color: IAMColors.white,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  'Proceed to Verification',
                                                  style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 26),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shield_rounded,
                                        size: 18,
                                        color: IAMColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Protected by IAM Wallet',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                          color: IAMColors.primary,
                                          fontWeight: FontWeight.w700,
                                          height: 1.25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletMetric extends StatelessWidget {
  const _WalletMetric({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.dark,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final chipBg = dark
        ? IAMColors.white.withOpacity(0.06)
        : IAMColors.white.withOpacity(0.9);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(dark ? 0.2 : 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: IAMSizes.md,
          vertical: IAMSizes.md - 1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).hintColor,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                  height: 1.1,
                  fontSize: 24,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IamWalletOtpVerificationPage extends StatefulWidget {
  const _IamWalletOtpVerificationPage({
    required this.orderRef,
    required this.totalAmount,
    required this.accountId,
    required this.initialBalance,
    this.initialMaskedEmail,
    required this.initialMessage,
  });

  final String orderRef;
  final num totalAmount;
  final String accountId;
  final num initialBalance;
  final String? initialMaskedEmail;
  final String initialMessage;

  @override
  State<_IamWalletOtpVerificationPage> createState() =>
      _IamWalletOtpVerificationPageState();
}

class _IamWalletOtpVerificationPageState
    extends State<_IamWalletOtpVerificationPage> {
  static const int _resendCooldownSeconds = 180;

  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _isPaying = false;
  bool _otpValidated = false;
  String? _statusText;
  bool _statusIsError = false;
  String? _otpError;
  String? _maskedOtpEmail;
  Timer? _resendCooldownTimer;
  int _resendSecondsLeft = _resendCooldownSeconds;

  bool get _isResendCoolingDown => _resendSecondsLeft > 0;
  String get _resendCooldownLabel {
    final minutes = (_resendSecondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_resendSecondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _statusText = widget.initialMessage;
    _maskedOtpEmail =
        widget.initialMaskedEmail?.trim().isNotEmpty == true
        ? widget.initialMaskedEmail!.trim()
        : _extractAndMaskEmail(widget.initialMessage);
    _startResendCooldown();
  }

  String? _extractAndMaskEmail(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    final emailRegex = RegExp(
      r'([a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,})',
    );
    final match = emailRegex.firstMatch(text);
    final email = match?.group(0);
    if (email == null || email.isEmpty) return null;
    return _maskEmail(email);
  }

  String _maskEmail(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex <= 0 || atIndex == email.length - 1) return email;
    final local = email.substring(0, atIndex);
    final domain = email.substring(atIndex + 1);
    if (local.length <= 1) {
      return '${local.substring(0, 1)}***@$domain';
    }
    return '${local.substring(0, 1)}***@$domain';
  }

  @override
  void dispose() {
    _resendCooldownTimer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendCooldown() {
    _resendCooldownTimer?.cancel();
    setState(() => _resendSecondsLeft = _resendCooldownSeconds);
    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSecondsLeft <= 1) {
        timer.cancel();
        setState(() => _resendSecondsLeft = 0);
        return;
      }
      setState(() => _resendSecondsLeft -= 1);
    });
  }

  String get _otpValue => _otpControllers.map((c) => c.text).join();

  void _clearOtpInput() {
    for (final c in _otpControllers) {
      c.clear();
    }
  }

  void _focusOtpIndex(int index) {
    if (index < 0 || index >= _otpFocusNodes.length) return;
    _otpFocusNodes[index].requestFocus();
  }

  void _clearOtpError() {
    if (_otpError == null) return;
    setState(() => _otpError = null);
  }

  Future<void> _sendOtp({bool isResend = false}) async {
    if (_isSendingOtp || _isVerifyingOtp || _isPaying || _otpValidated) return;

    setState(() {
      _isSendingOtp = true;
      _statusIsError = false;
      _otpError = null;
    });

    final res = await ApiMiddleware.wallet.sendOtp(orderRefNo: widget.orderRef);
    if (!mounted) return;

    setState(() {
      _isSendingOtp = false;
      if (res.success) {
        _otpValidated = false;
        _clearOtpInput();
        final data = res.data;
        final maskedFromData = data?.maskedEmail.trim();
        final rawFromData = data?.emailAddress.trim();
        _maskedOtpEmail =
            (maskedFromData != null && maskedFromData.isNotEmpty)
            ? maskedFromData
            : (rawFromData != null && rawFromData.isNotEmpty)
            ? _maskEmail(rawFromData)
            : _extractAndMaskEmail(res.message) ?? _maskedOtpEmail;
        _statusText = res.message.isNotEmpty
            ? res.message
            : isResend
            ? 'A new OTP has been sent to your registered contact.'
            : 'OTP has been sent to your registered contact.';
        _statusIsError = false;
        _focusOtpIndex(0);
        _startResendCooldown();
      } else {
        _statusText = res.message.isNotEmpty
            ? res.message
            : 'Unable to send wallet OTP.';
        _statusIsError = true;
      }
    });
  }

  Future<void> _validateOtpCode() async {
    if (_isVerifyingOtp || _isSendingOtp || _isPaying || _otpValidated) return;

    final otpCode = _otpValue.trim();
    if (otpCode.length != 6) {
      setState(() => _otpError = 'Enter the 6-digit OTP code.');
      return;
    }

    _clearOtpError();
    setState(() {
      _isVerifyingOtp = true;
      _statusIsError = false;
    });

    final res = await ApiMiddleware.wallet.validateOtp(
      orderRefNo: widget.orderRef,
      otpCode: otpCode,
    );
    if (!mounted) return;

    setState(() {
      _isVerifyingOtp = false;
      _otpValidated = res.success;
      if (res.success) {
        _statusText = res.message.isNotEmpty
            ? res.message
            : 'OTP verified. You can now confirm your payment.';
        _statusIsError = false;
      } else {
        _otpError = res.message.isNotEmpty ? res.message : 'Invalid OTP code.';
        _statusText = res.message.isNotEmpty
            ? res.message
            : 'Unable to validate OTP.';
        _statusIsError = true;
      }
    });
  }

  Future<void> _confirmPayment() async {
    if (_isPaying || _isSendingOtp || _isVerifyingOtp) return;
    if (!_otpValidated) {
      setState(() {
        _statusText = 'OTP verification is required before wallet payment.';
        _statusIsError = true;
      });
      return;
    }

    setState(() {
      _isPaying = true;
      _statusIsError = false;
    });

    final res = await ApiMiddleware.wallet.payOrder(
      amount: widget.totalAmount,
      orderRefNo: widget.orderRef,
      remarks: 'Wallet payment',
    );
    if (!mounted) return;

    setState(() => _isPaying = false);

    if (!res.success) {
      setState(() {
        _statusText = res.message.isNotEmpty
            ? res.message
            : 'Wallet payment was not completed.';
        _statusIsError = true;
      });
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final amountText = IAMFormatter.formatCurrency(
      widget.totalAmount.toDouble(),
    );
    final balanceText = IAMFormatter.formatCurrency(
      widget.initialBalance.toDouble(),
    );
    final onSurface = dark ? IAMColors.white : IAMColors.black;
    final surface = dark ? const Color(0xFF101217) : IAMColors.white;
    final muted = onSurface.withOpacity(dark ? 0.72 : 0.66);
    final otpFillColor = dark
        ? IAMColors.white.withOpacity(0.08)
        : IAMColors.primary.withOpacity(0.08);
    final otpBorderColor = _otpError == null
        ? IAMColors.primary.withOpacity(dark ? 0.75 : 0.45)
        : Theme.of(context).colorScheme.error;
    final resendEnabled =
        !_isPaying &&
        !_isSendingOtp &&
        !_isVerifyingOtp &&
        !_otpValidated &&
        !_isResendCoolingDown;
    final hasSufficientBalance =
        widget.initialBalance >= widget.totalAmount;

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: onSurface,
        iconTheme: IconThemeData(
          color: dark ? IAMColors.white : IAMColors.black,
        ),
        title: const Text('Verify OTP'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: onSurface.withOpacity(dark ? 0.14 : 0.1),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: dark
                        ? [IAMColors.black, IAMColors.black.withOpacity(0.92)]
                        : [IAMColors.white, IAMColors.softGrey],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(IAMSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (dark
                                      ? IAMColors.black
                                      : IAMColors.white)
                                  .withOpacity(dark ? 0.35 : 0.75),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: IAMColors.primary.withOpacity(
                                  dark ? 0.35 : 0.45,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Image.asset(
                              IAMImages.walletIcon,
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                              semanticLabel: 'IAM Wallet',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'IAM Wallet',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: onSurface,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Order ${widget.orderRef}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: muted,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.accountId.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Container(
                              width: 1,
                              height: 44,
                              color: onSurface.withOpacity(dark ? 0.18 : 0.12),
                            ),
                            Flexible(
                              child: Text(
                                'Account ID: ${widget.accountId}',
                                textAlign: TextAlign.right,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: muted,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _WalletMetric(
                            label: 'Wallet balance',
                            value: balanceText,
                            valueColor: IAMColors.primary,
                            dark: dark,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                hasSufficientBalance
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                size: 18,
                                color: hasSufficientBalance
                                    ? Colors.green[400]
                                    : Colors.red[400],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                hasSufficientBalance
                                    ? 'Sufficient Funds'
                                    : 'Insufficient Funds',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: hasSufficientBalance
                                          ? Colors.green[400]
                                          : Colors.red[400],
                                      fontWeight: FontWeight.w700,
                                      height: 1.25,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _WalletMetric(
                            label: 'Amount due',
                            value: amountText,
                            valueColor: onSurface,
                            dark: dark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.mail_outline_rounded,
                    size: 20,
                    color: muted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _maskedOtpEmail != null
                          ? 'Enter the 6-digit code sent to $_maskedOtpEmail.'
                          : 'Enter the 6-digit code sent to your registered email.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: muted,
                        height: 1.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              if (_statusText != null) ...[
                const SizedBox(height: 14),
                IAMRoundedContainer(
                  backgroundColor: _statusIsError
                      ? Colors.red.withOpacity(dark ? 0.2 : 0.1)
                      : Colors.green.withOpacity(dark ? 0.2 : 0.1),
                  borderColor: _statusIsError
                      ? Colors.red.withOpacity(dark ? 0.4 : 0.2)
                      : Colors.green.withOpacity(dark ? 0.4 : 0.2),
                  showBorder: true,
                  padding: const EdgeInsets.all(IAMSizes.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _statusIsError
                            ? Icons.error_outline_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 20,
                        color: _statusIsError
                            ? Colors.red[300]
                            : Colors.green[300],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _statusText!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: onSurface, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 8.0;
                  final rawWidth = (constraints.maxWidth - (spacing * 5)) / 6;
                  final cellWidth = rawWidth.clamp(44.0, 52.0);
                  const cellHeight = 64.0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Padding(
                        padding: EdgeInsets.only(right: i == 5 ? 0 : spacing),
                        child: SizedBox(
                          width: cellWidth,
                          height: cellHeight,
                          child: TextField(
                            controller: _otpControllers[i],
                            focusNode: _otpFocusNodes[i],
                            enabled:
                                !_isPaying &&
                                !_isSendingOtp &&
                                !_isVerifyingOtp,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            style: (Theme.of(context).textTheme.titleLarge ??
                                    const TextStyle())
                                .copyWith(
                                  color: onSurface,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  fontSize: 24,
                                ),
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(1),
                            ],
                            decoration: InputDecoration(
                              counterText: '',
                              errorText: null,
                              isDense: true,
                              filled: true,
                              fillColor: otpFillColor,
                              contentPadding: const EdgeInsets.symmetric(vertical: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: otpBorderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: otpBorderColor,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: otpBorderColor,
                                  width: 1.4,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: otpBorderColor.withOpacity(0.5),
                                ),
                              ),
                            ),
                            onChanged: (v) {
                              _clearOtpError();
                              if (v.isNotEmpty) {
                                if (i < 5) {
                                  _focusOtpIndex(i + 1);
                                } else {
                                  FocusScope.of(context).unfocus();
                                }
                              } else if (i > 0) {
                                _focusOtpIndex(i - 1);
                              }
                            },
                            onSubmitted: (_) => _validateOtpCode(),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
              if (_otpError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _otpError!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  if (!_otpValidated) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (_isPaying || _isSendingOtp || _isVerifyingOtp)
                            ? null
                            : _validateOtpCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: IAMColors.primary,
                          foregroundColor: IAMColors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isVerifyingOtp
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: IAMColors.white,
                                ),
                              )
                            : const Text('Verify OTP'),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: resendEnabled
                            ? () => _sendOtp(isResend: true)
                            : null,
                        style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all(
                            const Size(0, 42),
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith<Color>((
                            states,
                          ) {
                            if (resendEnabled) return IAMColors.primary;
                            return Theme.of(context).disabledColor;
                          }),
                          overlayColor: WidgetStateProperty.all(
                            IAMColors.primary.withOpacity(0.08),
                          ),
                        ),
                        child: _isSendingOtp
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                _isResendCoolingDown
                                    ? 'Resend in $_resendCooldownLabel'
                                    : 'Resend OTP',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              IAMRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: IAMSizes.md,
                  vertical: IAMSizes.sm + 2,
                ),
                backgroundColor: dark
                    ? IAMColors.primary.withOpacity(0.16)
                    : IAMColors.primary.withOpacity(0.12),
                borderColor: onSurface.withOpacity(dark ? 0.14 : 0.08),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: IAMColors.primary.withOpacity(0.95),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'For your security, do not share your OTP with anyone.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: onSurface.withOpacity(0.82),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_otpValidated) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isPaying || _isSendingOtp || _isVerifyingOtp)
                        ? null
                        : _confirmPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: IAMColors.primary,
                      foregroundColor: IAMColors.white,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isPaying
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: IAMColors.white,
                            ),
                          )
                        : Text(
                            'Confirm payment',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
              const SizedBox(height: 26),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shield_rounded,
                                        size: 18,
                                        color: IAMColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Protected by IAM Wallet',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                          color: IAMColors.primary,
                                          fontWeight: FontWeight.w700,
                                          height: 1.25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

          ),
        ),
      ),
    );
  }
}
