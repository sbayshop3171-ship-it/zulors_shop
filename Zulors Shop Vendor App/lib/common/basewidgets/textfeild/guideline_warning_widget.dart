import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_asset_image_widget.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';

enum GuidelineStatus {success, warning, error}

class GuidelineWarningWidget extends StatelessWidget {
  final Widget content;
  final bool showCrossButton;
  final Function? onPressed;
  final GuidelineStatus guidelineStatus;
  const GuidelineWarningWidget({super.key, required this.content, required this.showCrossButton, this.onPressed, required this.guidelineStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: guidelineStatus == GuidelineStatus.warning ?
          Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.15) :
          guidelineStatus == GuidelineStatus.success ?
          Theme.of(context).colorScheme.onTertiaryContainer.withValues(alpha: 0.15) :
          guidelineStatus == GuidelineStatus.error ?
          Theme.of(context).colorScheme.error.withValues(alpha: 0.15) :
          Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.15)
      ),
      padding: const EdgeInsets.only(
        top: Dimensions.paddingSizeSmall,
        left: Dimensions.paddingSizeSmall,
        right: Dimensions.paddingSizeSmall,
        bottom: Dimensions.paddingSizeSmall
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
            child: CustomAssetImageWidget(
              guidelineStatus == GuidelineStatus.warning ?
              Images.infoIconGuideline :
              guidelineStatus == GuidelineStatus.success ?
              Images.guidelineSuccessIcon :
              guidelineStatus == GuidelineStatus.error ?
              Images.guidelineErrorIcon : Images.infoIconGuideline,
              width: 15, height: 15
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: content),

          if(showCrossButton)...[
            const SizedBox(width: Dimensions.paddingSizeSmall),
            InkWell(
              onTap: () {
                onPressed!();
              },
              child: const CustomAssetImageWidget(Images.crossIconGuideline, width: 15, height: 15)
            ),
          ]

        ],
      ),

    );
  }
}



// RichText(
//   text: TextSpan(
//     style: DefaultTextStyle.of(context).style,
//     children: <TextSpan>[
//       TextSpan(text: 'This is normal text. '),
//       TextSpan(
//         text: 'This is bold text. ',
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//       TextSpan(text: 'Back to normal text. '),
//       TextSpan(
//         text: 'Bold with underline and color!',
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           decoration: TextDecoration.underline,
//           color: Colors.amber[700], // Custom color
//         ),
//       ),
//     ],
//   ),
// )


///apply coupon calculation