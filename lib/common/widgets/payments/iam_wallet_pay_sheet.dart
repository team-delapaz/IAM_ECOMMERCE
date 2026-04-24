import 'package:flutter/material.dart';
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
    builder: (_) => _IamWalletPaySheet(orderRef: orderRef, totalAmount: totalAmount),
  );
  return result ?? false;
}

class _WalletModalSideAccent extends StatelessWidget {
  const _WalletModalSideAccent({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final gold = IAMColors.primary;
    return Container(
      width: 108,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? [
                  gold.withOpacity(0.22),
                  gold.withOpacity(0.06),
                  const Color(0xFF101217),
                ]
              : [
                  gold.withOpacity(0.18),
                  const Color(0xFFFFF8E1).withOpacity(0.55),
                  IAMColors.lightGrey,
                ],
        ),
        border: Border(
          right: BorderSide(
            color: (dark ? IAMColors.white : IAMColors.black).withOpacity(0.08),
          ),
        ),
      ),
      child: SafeArea(
        left: true,
        top: false,
        bottom: false,
        right: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (dark ? IAMColors.black : IAMColors.white).withOpacity(
                    dark ? 0.35 : 0.75,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: gold.withOpacity(dark ? 0.35 : 0.45),
                    width: 1,
                  ),
                ),
                child: Image.asset(
                  IAMImages.walletIcon,
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                  semanticLabel: 'IAM Wallet',
                ),
              ),
              const Spacer(),
              Icon(
                Icons.verified_user_outlined,
                size: 20,
                color: gold.withOpacity(0.85),
              ),
              const SizedBox(height: 6),
              Text(
                'Secure',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: (dark ? IAMColors.white : IAMColors.textPrimary)
                          .withOpacity(0.55),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IamWalletPaySheet extends StatefulWidget {
  const _IamWalletPaySheet({
    required this.orderRef,
    required this.totalAmount,
  });

  final String orderRef;
  final num totalAmount;

  @override
  State<_IamWalletPaySheet> createState() => _IamWalletPaySheetState();
}

class _IamWalletPaySheetState extends State<_IamWalletPaySheet> {
  WalletBalanceData? _walletData;
  bool _loadingBalance = true;
  bool _isValidating = false;
  bool _isPaying = false;
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
    if (_isValidating || _isPaying) return false;
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

  Future<void> _payOrder() async {
    if (_isPaying || _isValidating) return;
    setState(() {
      _isPaying = true;
      _statusText = null;
      _statusIsError = false;
    });

    var isValidated = _validated;
    if (!isValidated) {
      isValidated = await _validateOrder(showSuccessMessage: false);
      if (!mounted) return;
      if (!isValidated) {
        setState(() => _isPaying = false);
        return;
      }
    }

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
    final surface = dark ? const Color(0xFF101217) : IAMColors.white;
    final onSurface = dark ? IAMColors.white : IAMColors.black;
    final muted = onSurface.withOpacity(dark ? 0.72 : 0.66);
    final amountText = IAMFormatter.formatCurrency(widget.totalAmount.toDouble());
    final balance = _walletData?.balance ?? 0;
    final balanceText = IAMFormatter.formatCurrency(balance.toDouble());
    final canPay = !_loadingBalance && !_isPaying && !_isValidating;
    final hasSufficientBalance = !_loadingBalance && balance >= widget.totalAmount;

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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _WalletModalSideAccent(dark: dark),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              IAMSizes.md,
                              12,
                              4,
                              8,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
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
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.orderRef.isNotEmpty
                                            ? 'Order ${widget.orderRef}'
                                            : 'Wallet checkout',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: muted,
                                              height: 1.2,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Close',
                                  onPressed: _isPaying
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
                                                IAMColors.black.withOpacity(0.92),
                                              ]
                                            : [
                                                IAMColors.white,
                                                IAMColors.softGrey,
                                              ],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(IAMSizes.md),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _WalletMetric(
                                              label: 'Wallet balance',
                                              value: _loadingBalance
                                                  ? '…'
                                                  : balanceText,
                                              valueColor: _loadingBalance
                                                  ? muted
                                                  : IAMColors.primary,
                                              dark: dark,
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 52,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            color: onSurface.withOpacity(0.1),
                                          ),
                                          Expanded(
                                            child: _WalletMetric(
                                              label: 'Amount due',
                                              value: amountText,
                                              valueColor: onSurface,
                                              dark: dark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (_walletData != null) ...[
                                    const SizedBox(height: 12),
                                    IAMRoundedContainer(
                                      showBorder: true,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: IAMSizes.sm,
                                        vertical: 8,
                                      ),
                                      backgroundColor: dark
                                          ? IAMColors.black.withOpacity(0.45)
                                          : IAMColors.accent.withOpacity(0.35),
                                      borderColor: IAMColors.primary.withOpacity(
                                        dark ? 0.28 : 0.22,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.badge_outlined,
                                            size: 18,
                                            color: IAMColors.primary.withOpacity(
                                              0.9,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Account ${_walletData!.accountId}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge
                                                  ?.copyWith(
                                                    color: onSurface.withOpacity(
                                                      0.88,
                                                    ),
                                                    fontWeight: FontWeight.w600,
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
                                      padding: const EdgeInsets.all(IAMSizes.md),
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
                                  const SizedBox(height: 20),
                                  Text(
                                    'Step 1 — confirm funds. Step 2 — charge wallet.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: muted,
                                          height: 1.3,
                                        ),
                                  ),
                                  if (!hasSufficientBalance) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Insufficient balance. Reload your IAM Wallet.',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.red.shade400,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: (canPay && hasSufficientBalance) ? _payOrder : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: IAMColors.primary,
                                        foregroundColor: IAMColors.white,
                                        elevation: dark ? 0 : 2,
                                        shadowColor: IAMColors.primary.withOpacity(
                                          0.45,
                                        ),
                                        minimumSize: const Size.fromHeight(54),
                                        disabledBackgroundColor: IAMColors.grey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: (_isPaying || _isValidating)
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                color: IAMColors.white,
                                              ),
                                            )
                                          : Text(
                                              'Pay $amountText',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15,
                                              ),
                                            ),
                                    ),
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
          horizontal: IAMSizes.sm,
          vertical: IAMSizes.sm + 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).hintColor,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                    height: 1.1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

