import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_asset_image_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class StatusChangeBottomSheetWidget extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Function onYesPressed;
  final Function onNoPressed;
  final bool? isLoading;
  const StatusChangeBottomSheetWidget({super.key, required this.title, this.subtitle, required this.onYesPressed, required this.onNoPressed, this.isLoading = false});

  @override
  State<StatusChangeBottomSheetWidget> createState() => _StatusChangeBottomSheetWidgetState();
}

class _StatusChangeBottomSheetWidgetState extends State<StatusChangeBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(Dimensions.radiusExtraLarge),
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const CustomAssetImageWidget(Images.closeIcon, width: 20, height: 20),
              ),
            ),
          ),

          
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              children: [
                const CustomAssetImageWidget(Images.powerIcons, width: 50, height: 50),
            
                Text(widget.title, style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeDefault),
            
                Text(
                  widget.subtitle ?? '',
                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall),
                  textAlign: TextAlign.center
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Row(
                  children: [
                    Expanded(
                      child: CustomButtonWidget(
                        backgroundColor: Theme.of(context).hintColor,
                        btnTxt: getTranslated('no', context),
                        onTap: () {
                          Navigator.pop(context);
                        }
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(
                      child: (widget.isLoading ?? false) ?
                      const Center(child: CircularProgressIndicator())
                        : CustomButtonWidget(
                        btnTxt: getTranslated('yes', context),
                        onTap: widget.onYesPressed,
                      ),
                    )
                  ],
                ),
                
              ],
            ),
          ),


        ],
      ),

    );
  }
}
