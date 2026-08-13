import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/digital_product_controller.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';


class UploadPreviewFileWidget extends StatefulWidget {
  final Product? product;
  const UploadPreviewFileWidget({super.key, this.product});

  @override
  State<UploadPreviewFileWidget> createState() => _UploadPreviewFileWidgetState();
}

class _UploadPreviewFileWidgetState extends State<UploadPreviewFileWidget> {
  final tooltipController = JustTheController();

  @override
  void initState() {
    if(widget.product!= null && widget.product?.previewFileFullUrl != null && widget.product?.previewFileFullUrl?.path != null && widget.product?.previewFileFullUrl?.path != '') {
      Provider.of<DigitalProductController>(context,listen: false).setPreviewData(false);
    } else {
      Provider.of<DigitalProductController>(context,listen: false).setPreviewData(true);
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<DigitalProductController>(
        builder: (context, digitalProductController, child) {
        return Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text( getTranslated('upload_preview_file', context)!, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              JustTheTooltip(
                backgroundColor: Colors.black87,
                controller: tooltipController,
                preferredDirection: AxisDirection.up,
                tailLength: 10,
                tailBaseWidth: 20,
                content: Container(width: 250,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Text(getTranslated('upload_a_suitable_file', context)!,
                    style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault))),
                child: InkWell(onTap: ()=>  tooltipController.showTooltip(),
                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                    child: SizedBox(width: 20, child: Image.asset(Images.infoIcon)),
                  ),
                ),
              )

              ],
            )
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D1B7FED), // 0x0D is the hex value for 5% opacity
                      offset: Offset(0, 6),
                      blurRadius: 12,
                      spreadRadius: -3,
                    ),
                    BoxShadow(
                      color: Color(0x0D1B7FED), // 0x0D is the hex value for 5% opacity
                      offset: Offset(0, -6),
                      blurRadius: 12,
                      spreadRadius: -3,
                    ),
                  ]
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha:0.10),
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingEye)),
                        color: Theme.of(context).highlightColor,
                      ),
                      child: DottedBorder(
                          options: RoundedRectDottedBorderOptions (
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            dashPattern: const [4,5],
                            color: (!digitalProductController.isPreviewNull || digitalProductController.digitalProductPreview != null ) ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                            radius: const Radius.circular(Dimensions.paddingEye),
                          ),
                          child: Container(
                            height: 110,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                            child: Stack(
                              children: [

                                if(!digitalProductController.isPreviewNull || digitalProductController.digitalProductPreview != null )
                                  Positioned(
                                      top: 10,
                                      right: 10,
                                      child: InkWell(
                                          onTap: () {
                                            if(!digitalProductController.isPreviewNull) {
                                              digitalProductController.deleteDigitalPreviewFile(widget.product?.id);
                                            } else {
                                              digitalProductController.deleteDigitalPreviewFile(null);
                                            }
                                          } ,
                                          child: digitalProductController.isPreviewLoading ? const Center(child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator())) : Image.asset(width:25, Images.digitalPreviewDeleteIcon))
                                  ),

                                Positioned.fill(
                                  child: Center(
                                    child:Column(
                                      mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [

                                        if(digitalProductController.digitalProductPreview == null && digitalProductController.isPreviewNull)
                                          ...[
                                            InkWell(
                                              onTap: () => digitalProductController.pickFileDigitalProductPreview(),
                                              child: Column(
                                                children: [
                                                  SizedBox(width: 30, child: Image.asset(Images.uploadIcon)),
                                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                                  Text(getTranslated('upload_file', context)!,
                                                    style: robotoRegular.copyWith(fontWeight: FontWeight.w600, fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color))
                                                ],
                                              ),
                                            )
                                          ],


                                        if(digitalProductController.digitalProductPreview != null)
                                        ...[
                                          Column(
                                            children: [
                                              SizedBox(width: 30, child: Image.asset(Images.digitalPreviewFileIcon) ),
                                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                              Text(digitalProductController.digitalProductPreview?.name ?? '',
                                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), overflow: TextOverflow.ellipsis,)
                                            ],
                                          )
                                        ],


                                        if(digitalProductController.digitalProductPreview == null && !digitalProductController.isPreviewNull)
                                        ...[
                                          Column(
                                            children: [
                                              SizedBox(width: 30, child: Image.asset(Images.digitalPreviewFileIcon)),
                                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                              Text(widget.product?.previewFileFullUrl?.key ?? '',
                                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)
                                              )
                                            ],
                                          )
                                        ],

                                      ],
                                    ),
                                  ),
                                ),



                              ],
                            )
                        )
                      ),
                    ),
                  ),


              ],
              ),
            ),
          ),
        ],
        );
      }
    );
  }
}
