import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
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
                      const Icon(Iconsax.document_text, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        "Terms & Conditions",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "By using the IAM Worldwide shopping application, you agree to the following terms.",
                    style: TextStyle(height: 1.6),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Account Responsibility",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Users must provide accurate information when creating an account.",
                    style: TextStyle(height: 1.6),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Product Purchases",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "All purchases made through the platform are subject to availability and pricing confirmation.",
                    style: TextStyle(height: 1.6),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Payments",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Payments must be completed through the available payment methods provided in the application.",
                    style: TextStyle(height: 1.6),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "User Conduct",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Users must not misuse the platform, attempt fraud, or interfere with system security.",
                    style: TextStyle(height: 1.6),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Product Information",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "IAM Worldwide strives to ensure accurate product descriptions but does not guarantee that all content is error-free.",
                    style: TextStyle(height: 1.6),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Limitation of Liability",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "IAM Worldwide shall not be liable for indirect damages resulting from the use of the application.",
                    style: TextStyle(height: 1.6),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Changes to Terms",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "IAM Worldwide reserves the right to update these terms at any time.",
                    style: TextStyle(height: 1.6),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Agreement",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "By continuing to use this application, you agree to these terms.",
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
