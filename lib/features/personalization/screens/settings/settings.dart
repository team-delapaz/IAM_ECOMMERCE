import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:iam_ecomm/common/widgets/list_tiles/settings_menu_tile.dart';
import 'package:iam_ecomm/common/widgets/list_tiles/user_profile_tile.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/personalization/screens/help_center/help_center.dart';
import 'package:iam_ecomm/utils/theme/theme_controller.dart';
import 'package:iam_ecomm/features/personalization/screens/address/address.dart';
import 'package:iam_ecomm/features/personalization/screens/profile/profile.dart';
import 'package:iam_ecomm/features/shop/screens/cart/cart.dart';
import 'package:iam_ecomm/features/shop/screens/order/order.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late Future<ApiResponse<PointsBalanceData?>> _pointsFuture;

  @override
  void initState() {
    super.initState();
    _pointsFuture = ApiMiddleware.points.getBalance();
  }

  Future<void> _refreshPoints() async {
    setState(() {
      _pointsFuture = ApiMiddleware.points.getBalance();
    });
    await _pointsFuture;
  }

  void _showReferralIdSheet() {
    final referralId = AuthController.instance.user.value?.idno.trim() ?? '';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReferralIdSheet(
        referralId: referralId,
        onCopy: () => _copyReferralId(referralId),
        onShare: () => _shareReferralId(referralId),
      ),
    );
  }

  void _copyReferralId(String referralId) {
    if (referralId.isEmpty) {
      _showMessage('No referral ID available.');
      return;
    }

    Clipboard.setData(ClipboardData(text: referralId));
    _showMessage('Referral ID copied.');
  }

  Future<void> _shareReferralId(String referralId) async {
    if (referralId.isEmpty) {
      _showMessage('No referral ID available.');
      return;
    }

    await Share.share('Use my IAM Ecomm referral code: $referralId');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshPoints,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              //HEADER
              IAMPrimaryHeaderContainer(
                child: Column(
                  children: [
                    IAMAppBar(
                      title: Text(
                        'Account',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .apply(color: IAMColors.white),
                      ),
                    ),

                    //user profile card
                    IAMUserProfile(
                      onPressed: () => Get.to(() => const ProfileScreen()),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: IAMSizes.defaultSpace,
                      ),
                      child: _PointsBalanceView(pointsFuture: _pointsFuture),
                    ),
                    const SizedBox(height: IAMSizes.spaceBtwSections),
                  ],
                ),
              ),

              //body
              Padding(
                padding: EdgeInsets.all(IAMSizes.defaultSpace),
                child: Column(
                  children: [
                    //  ACCOUNT SETTIGNS
                    IAMSectionHeading(
                      title: 'Account Settings',
                      showActionButton: false,
                    ),
                    SizedBox(height: IAMSizes.spaceBtwItems),

                    IAMSettingMenu(
                      icon: Iconsax.ticket_star,
                      title: 'My Referral ID',
                      subTitle: 'Show and share your referral code',
                      onTap: _showReferralIdSheet,
                    ),
                    IAMSettingMenu(
                      icon: Iconsax.home,
                      title: 'My Addresses',
                      subTitle: 'Delivery Address',
                      onTap: () => Get.to(() => const UserAddressScreen()),
                    ),
                    IAMSettingMenu(
                      icon: Iconsax.shopping_cart,
                      title: 'My Cart',
                      subTitle: 'Items added to Cart',
                      onTap: () => Get.to(() => const CartScreen()),
                    ),
                    IAMSettingMenu(
                      icon: Iconsax.bag_tick,
                      title: 'My Orders',
                      subTitle: 'Track In-Progress and Completed Orders',
                      onTap: () => Get.to(() => const OrderScreen()),
                    ),

                  /*IAMSettingMenu(
                    icon: Iconsax.bank,
                    title: 'Bank Account',
                    subTitle: 'Manage Connected Banks',
                  ),*/

                  // IAMSettingMenu(
                  //   icon: Iconsax.discount_shape,
                  //   title: 'Vouchers',
                  //   subTitle: 'Manage Discount Coupons',
                  // ),

                  /*IAMSettingMenu(
                    icon: Iconsax.gift,
                    title: 'Invite Friends',
                    subTitle: 'Share Referral Code',
                  ),*/

                  //INVITE FRIENDS VIEWS USER ID WHRE USERS CAN COPY AND WILL THEN SEND A DOWNLOADABLE APP URL WITH THEIR REFERRAL CODE AUTOMATICALLY INSERTED
                    IAMSettingMenu(
                      icon: Iconsax.message_question,
                      title: 'Help Center',
                      subTitle: 'FAQs',
                      onTap: () => Get.to(() => const HelpCenterScreen()),
                    ),
                  // IAMSettingMenu(
                  //   icon: Iconsax.notification,
                  //   title: 'Notifications',
                  //   subTitle: 'Customize your Notifications',
                  // ),
                  // IAMSettingMenu(
                  //   icon: Iconsax.security_card,
                  //   title: 'Account Privacy',
                  //   subTitle: 'Manage security and privacy settings',
                  // ),

                  /// -- App Settings
                    SizedBox(height: IAMSizes.spaceBtwSections),
                    IAMSectionHeading(
                      title: 'App Settings',
                      showActionButton: false,
                    ),

                    SizedBox(height: IAMSizes.spaceBtwItems),
                  // IAMSettingMenu(
                  //   icon: Iconsax.document_upload,
                  //   title: 'Load Data',
                  //   subTitle: 'Upload Data to your Cloud Firebase',
                  // ),

                  /*IAMSettingMenu(
                    icon: Iconsax.location,
                    title: 'Geolocation',
                    subTitle:
                        'Use your current location to show nearby results',
                    trailing: Switch(value: true, onChanged: (value) {}),
                  ), */

                  // IAMSettingMenu
                  // IAMSettingMenu(
                  //   icon: Iconsax.security_user,
                  //   title: 'Safe Mode',
                  //   subTitle: 'Search result is safe for all ages',
                  //   trailing: Switch(value: false, onChanged: (value) {}),
                  // ),
                  //
                  //                  // Dark / Light Mode
                    IAMSettingMenu(
                      icon: Iconsax.moon,
                      title: 'Dark Mode',
                      subTitle: 'Switch between light and dark theme',
                      trailing: Obx(() {
                        final controller = ThemeController.instance;
                        return Switch(
                          value: controller.isDarkMode,
                          onChanged: controller.toggleTheme,
                        );
                      }),
                    ),
                  //
                  //
                  //// IAMSettingMenu
                  /*IAMSettingMenu(
                    icon: Iconsax.image,
                    title: 'HD Image Quality',
                    subTitle: 'Use high-quality images',
                    trailing: Switch(value: false, onChanged: (value) {}),
                  ),*/

                  //Logout Button
                    const SizedBox(height: IAMSizes.spaceBtwSections),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => AuthController.instance.logout(),
                        child: const Text('Logout'),
                      ),
                    ),
                    const SizedBox(height: IAMSizes.spaceBtwSections * 2.5),
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

class _PointsBalanceView extends StatelessWidget {
  const _PointsBalanceView({required this.pointsFuture});

  final Future<ApiResponse<PointsBalanceData?>> pointsFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<PointsBalanceData?>>(
      future: pointsFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final success =
            snapshot.data?.success == true && snapshot.data?.data != null;
        final data = snapshot.data?.data;
        final message = snapshot.data?.message ?? 'Unable to load points';

        if (!isLoading && !success) {
          return _PointsCardShell(
            child: Row(
              children: [
                const _PointsIcon(icon: Iconsax.star),
                const SizedBox(width: IAMSizes.sm),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.88),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          );
        }

        return _PointsCardShell(
          data: success ? data : null,
          child: Row(
            children: [
              Expanded(
                child: _PointMetricCard(
                  label: 'Total Points',
                  value: isLoading ? null : data?.totalPoints,
                  suffix: 'pts',
                  icon: Iconsax.medal_star,
                ),
              ),
              const SizedBox(width: IAMSizes.sm),
              Expanded(
                child: _PointMetricCard(
                  label: 'Referrals',
                  value: isLoading ? null : 0,
                  suffix: 'people',
                  icon: Iconsax.profile_2user,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReferralIdSheet extends StatelessWidget {
  const _ReferralIdSheet({
    required this.referralId,
    required this.onCopy,
    required this.onShare,
  });

  final String referralId;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final darkMode = IAMHelperFunctions.isDarkMode(context);
    final code = referralId.isEmpty ? 'N/A' : referralId;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          IAMSizes.md,
          0,
          IAMSizes.md,
          IAMSizes.md,
        ),
        padding: const EdgeInsets.all(IAMSizes.lg),
        decoration: BoxDecoration(
          color: darkMode ? IAMColors.dark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: darkMode ? IAMColors.darkerGrey : const Color(0xFFF1E8D2),
          ),
          boxShadow: [
            BoxShadow(
              color: IAMColors.black.withOpacity(0.14),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.72)),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF7D6),
                    Color(0xFFFFFFFF),
                    Color(0xFFE0B52D),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: IAMColors.primary.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Iconsax.ticket_star,
                      color: IAMColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: IAMSizes.md),
                  Text(
                    'My Referral Code',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: IAMColors.black,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: IAMSizes.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: IAMSizes.md,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.78),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE9D28A)),
                    ),
                    child: Text(
                      code,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: IAMColors.black,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: IAMSizes.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCopy,
                    icon: const Icon(Iconsax.copy, size: 18),
                    label: const Text('Copy'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(
                        color: darkMode
                            ? IAMColors.darkerGrey
                            : const Color(0xFFE3D6AD),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: IAMSizes.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Iconsax.share, size: 18),
                    label: const Text('Share Code'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: IAMColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PointsCardShell extends StatelessWidget {
  const _PointsCardShell({required this.child, this.data});

  final Widget child;
  final PointsBalanceData? data;

  @override
  Widget build(BuildContext context) {
    final darkMode = IAMHelperFunctions.isDarkMode(context);
    final canOpenDetails = data != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canOpenDetails ? () => _showPointsBreakdown(context, data!) : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(IAMSizes.md),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(darkMode ? 0.10 : 0.18),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.24)),
          ),
          child: child,
        ),
      ),
    );
  }
}

void _showPointsBreakdown(BuildContext context, PointsBalanceData data) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final darkMode = IAMHelperFunctions.isDarkMode(context);

      return SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            IAMSizes.md,
            0,
            IAMSizes.md,
            IAMSizes.md,
          ),
          padding: const EdgeInsets.fromLTRB(
            IAMSizes.lg,
            IAMSizes.md,
            IAMSizes.lg,
            IAMSizes.lg,
          ),
          decoration: BoxDecoration(
            color: darkMode ? IAMColors.dark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: darkMode ? IAMColors.darkerGrey : const Color(0xFFF1E8D2),
            ),
            boxShadow: [
              BoxShadow(
                color: IAMColors.black.withOpacity(0.14),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: IAMColors.primary.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Iconsax.medal_star,
                      color: IAMColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: IAMSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Points Breakdown',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: IAMSizes.xs),
                        Text(
                          'Account ${data.accountId}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: darkMode
                                        ? Colors.white70
                                        : IAMColors.darkerGrey,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: IAMSizes.lg),
              _PointsBreakdownRow(
                label: 'Total Points',
                value: data.totalPoints,
                icon: Iconsax.star_1,
                highlight: true,
              ),
              const SizedBox(height: IAMSizes.sm),
              _PointsBreakdownRow(
                label: 'Earned Points',
                value: data.earnedPoints,
                icon: Iconsax.cup,
              ),
              const SizedBox(height: IAMSizes.sm),
              _PointsBreakdownRow(
                label: 'Redeemed Points',
                value: data.redeemedPoints,
                icon: Iconsax.receipt_minus,
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PointsBreakdownRow extends StatelessWidget {
  const _PointsBreakdownRow({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final num value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final darkMode = IAMHelperFunctions.isDarkMode(context);
    final formatted = NumberFormat.decimalPattern().format(value);

    return Container(
      padding: const EdgeInsets.all(IAMSizes.md),
      decoration: BoxDecoration(
        color: highlight
            ? IAMColors.primary.withOpacity(darkMode ? 0.20 : 0.12)
            : (darkMode ? IAMColors.black : const Color(0xFFFAF8F2)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? IAMColors.primary.withOpacity(0.36)
              : (darkMode ? IAMColors.darkerGrey : const Color(0xFFF0E8D7)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: IAMColors.primary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: IAMColors.primary, size: 20),
          ),
          const SizedBox(width: IAMSizes.md),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            '$formatted pts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: highlight ? IAMColors.primary : null,
                ),
          ),
        ],
      ),
    );
  }
}

class _PointMetricCard extends StatelessWidget {
  const _PointMetricCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.icon,
  });

  final String label;
  final num? value;
  final String suffix;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final formatted = value == null
        ? '--'
        : NumberFormat.decimalPattern().format(value);

    return Container(
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.all(IAMSizes.sm),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          _PointsIcon(icon: icon),
          const SizedBox(width: IAMSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white.withOpacity(0.82),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: IAMSizes.xs),
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: formatted,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      TextSpan(
                        text: ' $suffix',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.white.withOpacity(0.84),
                              fontWeight: FontWeight.w600,
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
    );
  }
}

class _PointsIcon extends StatelessWidget {
  const _PointsIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
