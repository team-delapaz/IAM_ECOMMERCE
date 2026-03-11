import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:iam_ecomm/common/widgets/list_tiles/settings_menu_tile.dart';
import 'package:iam_ecomm/common/widgets/list_tiles/user_profile_tile.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/utils/theme/theme_controller.dart';
import 'package:iam_ecomm/features/personalization/screens/address/address.dart';
import 'package:iam_ecomm/features/personalization/screens/profile/profile.dart';
import 'package:iam_ecomm/features/shop/screens/cart/cart.dart';
import 'package:iam_ecomm/features/shop/screens/order/order.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            //HEADER
            IAMPrimaryHeaderContainer(
              child: Column(
                children: [
                  IAMAppBar(
                    title: Text(
                      'Account',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium!.apply(color: IAMColors.white),
                    ),
                  ),

                  //user profile card
                  IAMUserProfile(
                    onPressed: () => Get.to(() => const ProfileScreen()),
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
                  IAMSettingMenu(
                    icon: Iconsax.bank,
                    title: 'Bank Account',
                    subTitle: 'Manage Connected Banks',
                  ),
                  IAMSettingMenu(
                    icon: Iconsax.discount_shape,
                    title: 'Vouchers',
                    subTitle: 'Manage Discount Coupons',
                  ),
                  IAMSettingMenu(
                    icon: Iconsax.gift,
                    title: 'Invite Friends',
                    subTitle: 'Share and Referral Settings',
                  ),
                  //INVITE FRIENDS VIEWS USER ID WHRE USERS CAN COPY AND WILL THEN SEND A DOWNLOADABLE APP URL WITH THEIR REFERRAL CODE AUTOMATICALLY INSERTED
                  IAMSettingMenu(
                    icon: Iconsax.message_question,
                    title: 'Help Center',
                    subTitle: 'Help Articles and FAQs',
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
                  IAMSettingMenu(
                    icon: Iconsax.location,
                    title: 'Geolocation',
                    subTitle:
                        'Use your current location to show nearby results',
                    trailing: Switch(value: true, onChanged: (value) {}),
                  ), // IAMSettingMenu
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
                    trailing: Obx(
                      () {
                        final controller = ThemeController.instance;
                        return Switch(
                          value: controller.isDarkMode,
                          onChanged: controller.toggleTheme,
                        );
                      },
                    ),
                  ),
                  //
                  //
                  //// IAMSettingMenu
                  IAMSettingMenu(
                    icon: Iconsax.image,
                    title: 'HD Image Quality',
                    subTitle: 'Use high-quality images',
                    trailing: Switch(value: false, onChanged: (value) {}),
                  ),

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
    );
  }
}
