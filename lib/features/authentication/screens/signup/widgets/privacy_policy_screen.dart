import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.security_safe, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        "Privacy Policy",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "IAM Worldwide respects your privacy and is committed to protecting your personal information.",
                    style: TextStyle(height: 1.6),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Information We Collect",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "We may collect your name, email address, phone number, and other details when you create an account or place an order.",
                    style: TextStyle(height: 1.6),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "How We Use Your Information",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "• Process orders\n"
                    "• Provide customer support\n"
                    "• Improve our services\n"
                    "• Send important account notifications",
                    style: TextStyle(height: 1.6),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Data Protection",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "We implement security measures to ensure that your personal data is protected from unauthorized access.",
                    style: TextStyle(height: 1.6),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Third-Party Services",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "We may use trusted third-party services for payment processing, delivery, and analytics.",
                    style: TextStyle(height: 1.6),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Your Rights",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "You have the right to access, update, or delete your personal information.",
                    style: TextStyle(height: 1.6),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Contact Us",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "If you have questions regarding this Privacy Policy, please contact IAM Worldwide support.",
                    style: TextStyle(height: 1.6),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text("Accept"),
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
