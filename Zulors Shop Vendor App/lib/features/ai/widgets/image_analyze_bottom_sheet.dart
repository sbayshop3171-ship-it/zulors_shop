import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/ai/controllers/ai_controller.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

import '../../../main.dart';

class ImageAnalyzeBottomSheet extends StatefulWidget {
  final List<Language>? languageList;
  final TabController? tabController;
  final List<TextEditingController>? nameControllerList;
  final List<TextEditingController>? descriptionControllerList;
  const ImageAnalyzeBottomSheet({super.key, this.languageList, this.tabController, this.nameControllerList, this.descriptionControllerList});

  @override
  State<ImageAnalyzeBottomSheet> createState() => _ImageAnalyzeBottomSheetState();
}

class _ImageAnalyzeBottomSheetState extends State<ImageAnalyzeBottomSheet> {

  @override
  void initState() {
    super.initState();
    Provider.of<AiController>(context,listen: false).setRequestType(false, willUpdate: false);
    Provider.of<AiController>(context,listen: false).removeImage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      child: Consumer<AiController>(
        builder: (context, aiController, child) {
          return Column(mainAxisSize: MainAxisSize.min, children: [

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const SizedBox(width: 20),

              Container(
                height: 5, width: 35,
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.close, color: Theme.of(context).hintColor.withValues(alpha: 0.6), size: 22),
                ),
              ),
            ]),

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text(getTranslated('upload_image', context) ?? '', style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text( getTranslated('please_give_proper_image_to_generate_full_data_for_your_food', context) ?? '', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeSmall)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Row(children: [
                  CircleAvatar(backgroundColor: Theme.of(context).hintColor, radius: 3),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: Text( getTranslated('try_to_use_a_clean_and_avoid_blur_image', context) ?? '' , style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeSmall))),
                ]),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Row(children: [
                  CircleAvatar(backgroundColor: Theme.of(context).hintColor, radius: 3),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: Text(getTranslated('use_as_close_as_your_product_image', context)  ?? '', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeSmall))),
                ]),
                SizedBox(height: Dimensions.paddingSizeExtraLarge),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Column(children: [

                    Align(alignment: Alignment.center, child: Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        child: aiController.pickedLogo != null ? Image.file(
                          File(aiController.pickedLogo!.path), width: 150, height: 150, fit: BoxFit.cover,
                        ) : SizedBox(
                          width: 150, height: 150,
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(CupertinoIcons.camera_fill, color: Theme.of(context).hintColor.withValues(alpha: 0.5), size: 38),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Text(getTranslated('upload_image', context) ?? '', style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeExtraSmall)),

                          ]),
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0, top: 0, left: 0,
                        child: InkWell(
                          onTap: () => aiController.pickImage(true, false),
                          child: DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              color: Theme.of(context).primaryColor,
                              strokeWidth: 1,
                              strokeCap: StrokeCap.butt,
                              dashPattern: const [5, 5],
                              padding: const EdgeInsets.all(0),
                              radius: const Radius.circular(Dimensions.radiusDefault),
                            ),
                            child: Center(
                              child: Visibility(
                                visible: aiController.pickedLogo != null ? true : false,
                                child: Container(
                                  padding: const EdgeInsets.all(25),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 2, color: Colors.white),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ])),

                  ]),
                ),
                const SizedBox(height: 30),

                aiController.imageLoading ?
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Shimmer.fromColors(
                          baseColor: Theme.of(context).primaryColor,
                          highlightColor: Colors.grey[100]!,
                          child: Row(children: [
                            Icon(Icons.auto_awesome, color: Colors.blue),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            Text(getTranslated('generating', context) ?? '', style: robotoBold.copyWith(color: Colors.blue)),
                          ]),
                        )
                      ],
                    ),
                  ) :
                CustomButtonWidget(
                  isLoading: aiController.imageLoading,
                  backgroundColor : Theme.of(context).primaryColor,
                  onTap: () async {
                    if(aiController.pickedLogo == null) {
                      showCustomSnackBarWidget(getTranslated('please_upload_an_image', context) ?? '', context);
                    }else {
                      aiController.generateAndSetDataFromImage(image: aiController.pickedLogo!, tabController: widget.tabController, nameControllerList: widget.nameControllerList, languageList: widget.languageList)?.then(
                        (data) async {
                          await Future.delayed(Duration(milliseconds: 500));


                          if(data?.data != null) {
                            aiController.generateAddProductPageSetup(
                              data?.data ?? '',
                              widget.tabController,
                              widget.languageList,
                              widget.descriptionControllerList
                            );
                          }


                          if(data?.data != null) {
                            Navigator.of(Get.context!).pop();
                            Navigator.of(Get.context!).pop();
                          }

                      });
                    }
                  },
                  btnTxt: getTranslated('analyze_and_generate_content', context) ?? '',
                ),

              ]),
            ),

          ]);
        }
      )
    );
  }



}
