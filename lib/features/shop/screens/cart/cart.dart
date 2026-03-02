import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/features/shop/screens/cart/widgets/cart_items.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/checkout.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  double _calculateSubtotal() {
    // TODO: Replace this with your real cart item price calculation
    return 1500.00;
  }

  double _deliveryFee() {
    return 100.00;
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _calculateSubtotal();
    final delivery = _deliveryFee();
    final total = subtotal + delivery;

    return Scaffold(
      appBar: IAMAppBar(
        showBackArrow: true,
        title: Text('Cart', style: Theme.of(context).textTheme.headlineMedium),
      ),

      body: Padding(
        padding: const EdgeInsets.all(IAMSizes.defaultSpace),
        child: const IAMCartItems(),
      ),

      // 🔥 Bottom Summary Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(IAMSizes.defaultSpace),
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Order Summary Title
                      Text(
                        "Order Summary",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 20),

                      /// Subtotal
                      _buildRow("Subtotal", subtotal),

                      const SizedBox(height: 10),

                      /// Delivery Fee
                      _buildRow("Delivery Fee", delivery),

                      const SizedBox(height: 15),

                      const Divider(),

                      const SizedBox(height: 10),

                      /// Total
                      _buildRow("Total", total, isTotal: true),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Get.to(() => const CheckoutScreen());
                        },
                        child: const Text(
                          "Proceed to Checkout",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: const Text("View Order Summary"),
        ),
      ),
    );
  }

  /// 🔥 Reusable Row Builder (Left Label – Right Price)
  Widget _buildRow(String title, double price, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
        Text(
          "₱${price.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }
}
