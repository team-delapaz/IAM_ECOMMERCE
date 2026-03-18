import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/circular_container.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';

class IAMLoginHeaderContainer extends StatelessWidget {
  const IAMLoginHeaderContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IAMCurvedEdgeWidget(
      child: Container(
        color: IAMColors.primary,
        child: Stack(
          children: [
            Positioned(
              top: -150,
              right: -250,
              child: IAMCircularContainer(
                backgroundColor: IAMColors.textWhite.withOpacity(0.2),
              ),
            ),

            Positioned(
              top: 100,
              right: -300,
              child: IAMCircularContainer(
                backgroundColor: IAMColors.textWhite.withOpacity(0.2),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
