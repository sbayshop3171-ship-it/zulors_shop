import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class MetaSeoWidget extends StatelessWidget {
  const MetaSeoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddProductController>(
        builder: (context, resProvider, child){
        return Column(
          children: [

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(color: Theme.of(context).hintColor.withValues(alpha:0.50))
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                    RadioGroup<String>(
                      groupValue: resProvider.metaSeoInfo?.metaIndex,
                      onChanged: (value) {
                        if (value != null) {
                          resProvider.metaSeoInfo!.metaIndex = value;
                          resProvider.updateState();
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              resProvider.metaSeoInfo!.metaIndex = '1';
                              resProvider.updateState();
                            },
                            child: Row(children: [

                              SizedBox(height: 20, width: 20, child: Radio<String>(value: '1')),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Text(getTranslated('index', context)!, style: robotoTitleRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              )),
                            ]),
                          ),

                          const SizedBox(width: Dimensions.paddingSizeDefault),
                        ],
                      ),
                    ),


                    MetaSeoItem(
                        title: 'no_follow',
                        value: resProvider.metaSeoInfo?.metaNoFollow == 'nofollow' ? true : false,
                        callback: (bool? value){
                          resProvider.metaSeoInfo!.metaNoFollow = value == true ? 'nofollow' : '0';
                          resProvider.updateState();
                        },
                      ),

                      MetaSeoItem(
                        title: 'no_image_index',
                        value: resProvider.metaSeoInfo?.metaNoImageIndex == '1' ? true : false,
                        callback: (bool? value){
                          resProvider.metaSeoInfo!.metaNoImageIndex = value == true ? '1' : '0';
                          resProvider.updateState();
                        },
                      ),
                    ],
                  )),

                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                    RadioGroup<String>(
                      groupValue: resProvider.metaSeoInfo?.metaIndex,
                      onChanged: (value) {
                        if (value != null) {
                          resProvider.metaSeoInfo!.metaIndex = value;
                          resProvider.metaSeoInfo!.metaNoFollow = 'nofollow';
                          resProvider.metaSeoInfo!.metaNoImageIndex = '1';
                          resProvider.metaSeoInfo!.metaNoArchive = '1';
                          resProvider.metaSeoInfo!.metaNoSnippet = '1';
                          resProvider.updateState();
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              resProvider.metaSeoInfo!.metaIndex = 'noindex';
                              resProvider.metaSeoInfo!.metaNoFollow = 'nofollow';
                              resProvider.metaSeoInfo!.metaNoImageIndex = '1';
                              resProvider.metaSeoInfo!.metaNoArchive = '1';
                              resProvider.metaSeoInfo!.metaNoSnippet = '1';
                              resProvider.updateState();
                            },
                            child: Row(children: [

                              SizedBox(height: Dimensions.paddingSizeLarge, width: Dimensions.paddingSizeLarge, child: Radio<String>(value: 'noindex')),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Text(getTranslated('no_index', context)!, style: robotoTitleRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              )),
                            ]),
                          ),
                        ],
                      ),
                    ),

                    MetaSeoItem(
                        title: 'no_archive',
                        value: resProvider.metaSeoInfo?.metaNoArchive == '1' ? true : false,
                        callback: (bool? value){
                          resProvider.metaSeoInfo!.metaNoArchive = value == true ? '1' : '0';
                          resProvider.updateState();
                        },
                      ),

                      MetaSeoItem(
                        title: 'no_snippet',
                        value: resProvider.metaSeoInfo?.metaNoSnippet == '1' ? true : false,
                        callback: (bool? value){
                          resProvider.metaSeoInfo!.metaNoSnippet = value == true ? '1' : '0';
                          resProvider.updateState();
                        },
                      ),

                    ],
                  )),

                ],
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeExtraLarge),


            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(color: Theme.of(context).hintColor.withValues(alpha:0.50))
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 3,child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MetaSeoItem(
                      title: 'max_snippet',
                      value: resProvider.metaSeoInfo?.metaMaxSnippet == '1' ? true : false,
                      callback: (bool? value){
                        resProvider.metaSeoInfo!.metaMaxSnippet = value == true ? '1' : '0';
                        resProvider.updateState();
                      },
                    ),

                    MetaSeoItem(
                      title: 'max_video_preview',
                      value: resProvider.metaSeoInfo?.metaMaxVideoPreview == '1' ? true : false,
                      callback: (bool? value){
                        resProvider.metaSeoInfo!.metaMaxVideoPreview = value == true ? '1' : '0';
                        resProvider.updateState();
                      },
                    ),

                    MetaSeoItem(
                      title: 'max_image_preview',
                      value: resProvider.metaSeoInfo?.metaMaxImagePreview == '1' ? true : false,
                      callback: (bool? value){
                        resProvider.metaSeoInfo!.metaMaxImagePreview = value == true ? '1' : '0';
                        resProvider.updateState();
                      },
                    ),
                  ],
                )),

                Expanded( flex: 2, child: Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      child: SizedBox( height: 30,
                        child: CustomTextFieldWidget(
                          textInputType: TextInputType.number,
                          controller: resProvider.maxSnippetController,
                          onChanged: (value){
                            resProvider.metaSeoInfo?.metaMaxVideoPreviewValue = value;
                            resProvider.updateState();
                          },
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      child: SizedBox( height: 30,
                        child: CustomTextFieldWidget(
                          textInputType: TextInputType.number,
                          controller: resProvider.maxImagePreviewController,
                          onChanged: (value){
                            resProvider.metaSeoInfo?.metaMaxVideoPreviewValue = value;
                            resProvider.updateState();
                          },
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor,
                          border: Border.all(width: .7,color: Theme.of(context).hintColor.withValues(alpha:.3)),
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                        ),
                        child: DropdownButton<String>(
                          value: resProvider.imagePreviewSelectedType,
                          items: resProvider.imagePreviewType.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(getTranslated(value, context)!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            resProvider.setImagePreviewType(value!, true);
                          },
                          isExpanded: true,
                          underline: const SizedBox(),
                        ),
                      ),
                    ),
                  ],
                )),
              ],
              ),
            )
          ]
        );
      }
    );
  }
}




class MetaSeoItem extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool?) callback;

  const MetaSeoItem({super.key, required this.title, required this.value, required this.callback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(
          height: Dimensions.paddingSizeDefault, width: Dimensions.paddingSizeDefault,
          child: Checkbox(
            checkColor: Theme.of(context).cardColor,
            value: value,
            onChanged: callback,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Flexible(child: Text(getTranslated(title, context)!, maxLines: 2, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color))),
      ]),
    );
  }
}

