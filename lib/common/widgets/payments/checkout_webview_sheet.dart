import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/device/device_utility.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<bool> showCheckoutWebViewSheet({
  required BuildContext context,
  required String checkoutUrl,
  required String orderRef,
  required num totalAmount,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    builder: (_) {
      return CheckoutWebViewSheet(
        checkoutUrl: checkoutUrl,
        orderRef: orderRef,
        totalAmount: totalAmount,
      );
    },
  ).then((v) => v ?? false);
}

class CheckoutWebViewSheet extends StatefulWidget {
  final String checkoutUrl;
  final String orderRef;
  final num totalAmount;

  const CheckoutWebViewSheet({
    super.key,
    required this.checkoutUrl,
    required this.orderRef,
    required this.totalAmount,
  });

  @override
  State<CheckoutWebViewSheet> createState() => _CheckoutWebViewSheetState();
}

class _CheckoutWebViewSheetState extends State<CheckoutWebViewSheet> {
  WebViewController? _controller;
  int _progress = 0;
  late final bool _canEmbedWebView;
  double _dragOffsetY = 0;
  bool _isExiting = false;

  void _exit() {
    if (_isExiting) return;
    _isExiting = true;
    if (mounted) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  void initState() {
    super.initState();
    _canEmbedWebView =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);

    if (_canEmbedWebView) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (p) {
              if (!mounted) return;
              setState(() => _progress = p.clamp(0, 100));
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.checkoutUrl));
    } else {
      _progress = 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final surface = dark ? const Color(0xFF0F1115) : IAMColors.white;
    final onSurface = dark ? IAMColors.white : IAMColors.black;

    return FractionallySizedBox(
      heightFactor: 0.92,
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(dark ? 0.55 : 0.25),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Transform.translate(
          offset: Offset(0, _dragOffsetY),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 10),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: (details) {
                  if (_isExiting) return;
                  if (details.delta.dy <= 0) return;
                  setState(() {
                    _dragOffsetY = math.min(
                      _dragOffsetY + details.delta.dy,
                      220,
                    );
                  });
                },
                onVerticalDragEnd: (_) {
                  if (_isExiting) return;
                  const closeThreshold = 120.0;
                  if (_dragOffsetY >= closeThreshold) {
                    _exit();
                  } else {
                    setState(() => _dragOffsetY = 0);
                  }
                },
                child: SizedBox(
                  height: 28,
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: onSurface.withOpacity(dark ? 0.22 : 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: IAMSizes.defaultSpace,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: dark
                              ? [
                                  IAMColors.primary.withOpacity(0.95),
                                  IAMColors.primary.withOpacity(0.65),
                                ]
                              : [
                                  IAMColors.primary,
                                  IAMColors.primary.withOpacity(0.7),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.payments_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Secure checkout',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.orderRef.isNotEmpty
                                ? 'Order ${widget.orderRef} · ₱${widget.totalAmount.toStringAsFixed(2)}'
                                : 'Complete your payment to confirm the order.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: onSurface.withOpacity(0.72),
                                  height: 1.25,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: _exit,
                      icon: Icon(
                        Icons.close_rounded,
                        color: onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (_progress < 100)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: LinearProgressIndicator(
                    value: _progress / 100.0,
                    minHeight: 2.5,
                    backgroundColor: onSurface.withOpacity(dark ? 0.12 : 0.08),
                    color: IAMColors.primary,
                  ),
                )
              else
                const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: IAMSizes.defaultSpace,
                ),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: widget.checkoutUrl),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Checkout URL copied.',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green[300],
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copy'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: onSurface,
                        side: BorderSide(
                          color: onSurface.withOpacity(dark ? 0.22 : 0.18),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => IAMDeviceUtils.launchUrl(widget.checkoutUrl),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('Browser'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: onSurface,
                        side: BorderSide(
                          color: onSurface.withOpacity(dark ? 0.22 : 0.18),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: _canEmbedWebView ? () => _controller?.reload() : null,
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    IAMSizes.defaultSpace,
                    0,
                    IAMSizes.defaultSpace,
                    16,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: onSurface.withOpacity(dark ? 0.05 : 0.03),
                        border: Border.all(
                          color: onSurface.withOpacity(dark ? 0.14 : 0.10),
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: _canEmbedWebView
                          ? WebViewWidget(controller: _controller!)
                          : Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'In-app checkout isn’t available on Windows.',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: onSurface,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Tap “Browser” to open the secure checkout page.',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: onSurface.withOpacity(0.72),
                                          height: 1.25,
                                        ),
                                  ),
                                  const SizedBox(height: 14),
                                  SelectableText(
                                    widget.checkoutUrl,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: onSurface,
                                          height: 1.25,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

