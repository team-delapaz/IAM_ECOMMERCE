import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iam_ecomm/common/widgets/images/iam_circular_image.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<_ProfilePayloadBundle> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _profileFuture = _loadProfile();
    });
    await _profileFuture;
  }

  Future<_ProfilePayloadBundle> _loadProfile() async {
    final responses = await Future.wait<ApiResponse<MemberPayload?>>([
      ApiMiddleware.profile.getProfile(),
      ApiMiddleware.member.getMember(),
    ]);

    return _ProfilePayloadBundle(
      profile: responses[0],
      member: responses[1],
    );
  }

  void _copyId(String idno) {
    if (idno.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: idno.trim()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account ID copied'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = IAMHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: darkMode ? IAMColors.black : const Color(0xFFFAF8F2),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        backgroundColor: darkMode ? IAMColors.black : const Color(0xFFFAF8F2),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: IAMSizes.sm),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Iconsax.arrow_left),
            style: IconButton.styleFrom(
              backgroundColor: darkMode ? IAMColors.dark : const Color(0xFFF1EFE7),
              minimumSize: const Size(48, 48),
            ),
          ),
        ),
        actions: [
          const SizedBox(width: IAMSizes.sm),
          IconButton(
            onPressed: () {},
            icon: const Icon(Iconsax.setting_2),
            tooltip: 'Settings',
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
            ),
          ),
          const SizedBox(width: IAMSizes.sm),
        ],
      ),
      body: FutureBuilder<_ProfilePayloadBundle>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.hasUsableData) {
            final msg = snapshot.data?.message ?? 'Unable to load profile.';
            return _ProfileLoadState(message: msg, onRetry: _refreshProfile);
          }

          final data = snapshot.data!;
          final profile = data.profile.data;
          final member = data.member.data;
          final primary = data.primary;
          final authUser = AuthController.instance.user.value;
          final fullName = _firstNonEmpty([
            '${primary?.firstName ?? ''} ${primary?.lastName ?? ''}',
            authUser?.fullName,
            'IAM User',
          ]);
          final username = _firstNonEmpty([
            profile?.username,
            member?.username,
            authUser?.username,
          ]);
          final email = _firstNonEmpty([
            primary?.emailAddress,
            authUser?.emailAddress,
          ]);
          final phone = _firstNonEmpty([primary?.mobileNo, authUser?.mobileNo]);
          final idno = _firstNonEmpty([primary?.idno, authUser?.idno]);
          final address = _firstNonEmpty([primary?.homeAddress]);
          final country = _firstNonEmpty([primary?.country]);

          return RefreshIndicator(
            onRefresh: _refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                IAMSizes.md,
                IAMSizes.sm,
                IAMSizes.md,
                IAMSizes.spaceBtwSections,
              ),
              child: Column(
                children: [
                  _ProfileHeroCard(
                    name: fullName,
                    username: username,
                    accountId: idno,
                  ),
                  const SizedBox(height: IAMSizes.md),
                  _ProfileSection(
                    title: 'Account Details',
                    icon: Iconsax.security_user,
                    children: [
                      _ProfileInfoRow(
                        icon: Iconsax.user,
                        title: 'Name',
                        value: fullName,
                      ),
                      _ProfileInfoRow(
                        icon: Iconsax.sms,
                        title: 'Username',
                        value: username.isEmpty ? 'N/A' : username,
                      ),
                    ],
                  ),
                  const SizedBox(height: IAMSizes.md),
                  _ProfileSection(
                    title: 'Personal Details',
                    icon: Iconsax.profile_tick,
                    children: [
                      _ProfileInfoRow(
                        icon: Iconsax.card,
                        title: 'Account ID',
                        value: idno.isEmpty ? 'N/A' : idno,
                        trailingIcon: Iconsax.copy,
                        onTap: () => _copyId(idno),
                      ),
                      _ProfileInfoRow(
                        icon: Iconsax.direct,
                        title: 'Email',
                        value: email.isEmpty ? 'N/A' : email,
                      ),
                      _ProfileInfoRow(
                        icon: Iconsax.call,
                        title: 'Phone Number',
                        value: phone.isEmpty ? 'N/A' : phone,
                      ),
                      _ProfileInfoRow(
                        icon: Iconsax.location,
                        title: 'Address',
                        value: address.isEmpty ? 'N/A' : address,
                      ),
                      _ProfileInfoRow(
                        icon: Iconsax.global,
                        title: 'Country',
                        value: country.isEmpty ? 'N/A' : country,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final text = value?.trim();
    if (text != null && text.isNotEmpty) return text;
  }
  return '';
}

class _ProfilePayloadBundle {
  const _ProfilePayloadBundle({
    required this.profile,
    required this.member,
  });

  final ApiResponse<MemberPayload?> profile;
  final ApiResponse<MemberPayload?> member;

  MemberPayload? get primary => profile.data ?? member.data;

  bool get hasUsableData => primary != null && (profile.success || member.success);

  String get message {
    if (profile.message.trim().isNotEmpty) return profile.message;
    if (member.message.trim().isNotEmpty) return member.message;
    return 'Unable to load profile.';
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.name,
    required this.username,
    required this.accountId,
  });

  final String name;
  final String username;
  final String accountId;

  @override
  Widget build(BuildContext context) {
    final displayName = username.isEmpty ? name : username;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: IAMColors.primary.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF8D9),
            Color(0xFFFFFFFF),
            Color(0xFFF7C12B),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -48,
            left: -24,
            child: _SoftRing(size: 130, opacity: 0.24),
          ),
          Positioned(
            right: -42,
            bottom: -58,
            child: _SoftRing(size: 170, opacity: 0.28),
          ),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: IAMColors.primary.withOpacity(0.24),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const IAMCircularImage(
                        image: IAMImages.darkAppLogo,
                        width: 86,
                        height: 86,
                        padding: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: IAMSizes.md),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: IAMColors.black,
                        ),
                  ),
                ),
                const SizedBox(height: IAMSizes.xs),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    accountId.isEmpty ? 'Account ID: N/A' : 'Account ID: $accountId',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: IAMColors.darkerGrey,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                const SizedBox(height: IAMSizes.md),
                SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Iconsax.edit, size: 17),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: IAMColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: IAMColors.primary.withOpacity(0.34),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                    ),
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

class _SoftRing extends StatelessWidget {
  const _SoftRing({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(opacity), width: 1),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final darkMode = IAMHelperFunctions.isDarkMode(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: IAMSizes.sm),
      decoration: BoxDecoration(
        color: darkMode ? IAMColors.dark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: darkMode ? IAMColors.darkerGrey : const Color(0xFFF0E8D7),
        ),
        boxShadow: [
          if (!darkMode)
            BoxShadow(
              color: IAMColors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Row(
              children: [
                _IconBadge(icon: icon),
                const SizedBox(width: IAMSizes.sm),
                Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: IAMColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.trailingIcon = Iconsax.arrow_right_3,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final IconData trailingIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final darkMode = IAMHelperFunctions.isDarkMode(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            _IconBadge(icon: icon),
            const SizedBox(width: IAMSizes.sm),
            Expanded(
              flex: 3,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: darkMode ? Colors.white70 : IAMColors.black,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const SizedBox(width: IAMSizes.sm),
            Expanded(
              flex: 4,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: darkMode ? Colors.white : IAMColors.darkerGrey,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const SizedBox(width: IAMSizes.sm),
            Icon(
              trailingIcon,
              size: 18,
              color: darkMode ? Colors.white60 : IAMColors.darkerGrey,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: IAMColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: IAMColors.primary, size: 19),
    );
  }
}

class _ProfileLoadState extends StatelessWidget {
  const _ProfileLoadState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(IAMSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: IAMSizes.md),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
