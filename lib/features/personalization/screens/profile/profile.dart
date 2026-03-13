import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/images/iam_circular_image.dart';
import 'package:iam_ecomm/features/personalization/screens/profile/widgets/profile_information.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ApiResponse<MemberPayload?>> _memberFuture;

  @override
  void initState() {
    super.initState();
    _memberFuture = ApiMiddleware.member.getMember();
  }

  @override
  Widget build(BuildContext context) {
    ///////Integrated Member Profile
    return Scaffold(
      appBar: const IAMAppBar(showBackArrow: true, title: Text('Profile')),
      body: FutureBuilder<ApiResponse<MemberPayload?>>(
        future: _memberFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.success) {
            final msg = snapshot.data?.message ?? 'Unable to load profile.';
            return Center(child: Text(msg));
          }
          final member = snapshot.data!.data;
          final fullName =
              '${member?.firstName ?? ''} ${member?.lastName ?? ''}'.trim();
          final email = member?.emailAddress ?? '';
          final phone = member?.mobileNo ?? '';
          final idno = member?.idno ?? '';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(IAMSizes.defaultSpace),
              child: Column(
                children: [
                  //Profile Picture
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        const IAMCircularImage(
                          image: IAMImages.pandauser,
                          width: 80,
                          height: 80,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Change Profile Picture'),
                        ),
                      ],
                    ),
                  ),

                  //Details
                  const SizedBox(height: IAMSizes.spaceBtwItems / 2),
                  const Divider(),
                  const SizedBox(height: IAMSizes.spaceBtwItems),
                  const IAMSectionHeading(
                    title: 'Profile Information',
                    showActionButton: false,
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwItems),

                  ProfileInformation(
                    title: 'Name',
                    value: fullName.isEmpty ? 'IAM User' : fullName,
                    onPressed: () {},
                  ),
                  ProfileInformation(
                    title: 'Username',
                    value: idno.isEmpty ? '@iamusername' : idno,
                    onPressed: () {},
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwItems),
                  const Divider(),
                  const SizedBox(height: IAMSizes.spaceBtwItems),

                  //Heading Personal Info
                  const IAMSectionHeading(
                    title: 'Personal Information',
                    showActionButton: false,
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwItems),

                  ProfileInformation(
                    title: 'User ID',
                    value: idno.isEmpty ? 'N/A' : idno,
                    icon: Iconsax.copy,
                    onPressed: () {},
                  ),
                  ProfileInformation(
                    title: 'Email',
                    value: email.isEmpty ? 'N/A' : email,
                    onPressed: () {},
                  ),
                  ProfileInformation(
                    title: 'Phone Number',
                    value: phone.isEmpty ? 'N/A' : phone,
                    onPressed: () {},
                  ),
                  ProfileInformation(
                    title: 'Address',
                    value: member?.homeAddress ?? 'N/A',
                    onPressed: () {},
                  ),
                  ProfileInformation(
                    title: 'Country',
                    value: member?.country ?? 'N/A',
                    onPressed: () {},
                  ),
                  const Divider(),
                  const SizedBox(height: IAMSizes.spaceBtwItems),

                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
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
