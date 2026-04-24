import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class IAMBillingFulfillmentSection extends StatelessWidget {
  const IAMBillingFulfillmentSection({
    super.key,
    required this.isLoading,
    required this.fulfillmentTypes,
    required this.selectedFulfillmentTypeCode,
    required this.branches,
    required this.selectedBranchAreaCode,
    required this.onFulfillmentChanged,
    required this.onBranchChanged,
  });

  final bool isLoading;
  final List<FulfillmentTypeItem> fulfillmentTypes;
  final String selectedFulfillmentTypeCode;
  final List<BranchItem> branches;
  final String? selectedBranchAreaCode;
  final ValueChanged<String> onFulfillmentChanged;
  final ValueChanged<String?> onBranchChanged;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LinearProgressIndicator(minHeight: 2);
    }

    final hasTypes = fulfillmentTypes.isNotEmpty;
    final normalizedSelectedType = selectedFulfillmentTypeCode.trim();
    final selectedType = hasTypes &&
            fulfillmentTypes.any(
              (item) =>
                  item.fulfillmentTypeCode.trim().toUpperCase() ==
                  normalizedSelectedType.toUpperCase(),
            )
        ? normalizedSelectedType
        : null;
    final isPickup = normalizedSelectedType.toUpperCase() == 'PICKUP';
    final normalizedSelectedBranchCode = selectedBranchAreaCode?.trim();
    final branchItems = branches
        .where((branch) => branch.areaCode.trim().isNotEmpty)
        .toList();
    final hasBranches = branchItems.isNotEmpty;
    final selectedBranch = hasBranches &&
            normalizedSelectedBranchCode != null &&
            branchItems.any(
              (branch) => branch.areaCode.trim() == normalizedSelectedBranchCode,
            )
        ? normalizedSelectedBranchCode
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: selectedType,
          decoration: const InputDecoration(
            labelText: 'Fulfillment',
            hintText: 'Select delivery or pickup',
          ),
          items: fulfillmentTypes
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item.fulfillmentTypeCode.trim(),
                  child: Text(item.fulfillmentTypeName),
                ),
              )
              .toList(),
          onChanged: !hasTypes
              ? null
              : (value) {
                  if (value == null) return;
                  onFulfillmentChanged(value);
                },
        ),
        if (isPickup) ...[
          const SizedBox(height: IAMSizes.spaceBtwItems),
          DropdownButtonFormField<String>(
            value: selectedBranch,
            decoration: const InputDecoration(
              labelText: 'Pickup branch',
              hintText: 'Select a branch',
            ),
            items: branchItems
                .map(
                  (branch) => DropdownMenuItem<String>(
                    value: branch.areaCode.trim(),
                    child: Text('${branch.areaName} '),
                    //child: Text('${branch.areaName} (${branch.areaCode.trim()})'),
                  ),
                )
                .toList(),
            onChanged: !hasBranches ? null : onBranchChanged,
          ),
        ],
      ],
    );
  }
}
