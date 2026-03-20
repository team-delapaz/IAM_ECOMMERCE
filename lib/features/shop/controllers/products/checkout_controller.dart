import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/list_tiles/payment_tile.dart';
import 'package:iam_ecomm/features/shop/models/payment_method_model.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class CheckoutController extends GetxController {
  static CheckoutController get instance => Get.find();

  final Rx<PaymentMethodModel> selectedPaymentMethod =
      PaymentMethodModel.empty().obs;
  final RxString selectedPaymentProviderCode = ''.obs;
  final RxString selectedPaymentProviderName = ''.obs;

  @override
  void onInit() {
    selectedPaymentMethod.value = PaymentMethodModel(
      image: IAMImages.maya,
      name: 'Maya',
    );
    super.onInit();
  }

  void setPaymentProvider({required String code, required String name}) {
    selectedPaymentProviderCode.value = code;
    selectedPaymentProviderName.value = name;
    selectedPaymentMethod.value = PaymentMethodModel.empty();
  }

  void setPaymentMethod({required String name, required String image}) {
    selectedPaymentMethod.value = PaymentMethodModel(image: image, name: name);
  }

  void clearPaymentProvider() {
    selectedPaymentProviderCode.value = '';
    selectedPaymentProviderName.value = '';
    selectedPaymentMethod.value = PaymentMethodModel.empty();
  }

  Future<dynamic> selectPaymentMethod(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(IAMSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IAMSectionHeading(
                title: 'Select Payment Method',
                showActionButton: false,
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // -- MAYA
              IAMPaymentTile(
                paymentMethod: PaymentMethodModel(
                  image: IAMImages.maya,
                  name: 'Maya',
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems / 2),

              // -- IAM WALLET
              IAMPaymentTile(
                paymentMethod: PaymentMethodModel(
                  image: IAMImages.iamwallet,
                  name: 'IAM Wallet',
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems / 2),

              // -- COD
              IAMPaymentTile(
                paymentMethod: PaymentMethodModel(
                  image: IAMImages.cod,
                  name: 'Cash on Delivery',
                ),
              ),
              //const SizedBox(height: IAMSizes.spaceBtwItems / 2,),
            ],
          ),
        ),
      ),
    );
  }
}
