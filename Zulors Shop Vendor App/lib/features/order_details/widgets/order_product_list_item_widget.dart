import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/order_details/controllers/order_details_controller.dart';
import 'package:zulors_shop_vendor/features/order_details/domain/models/order_details_model.dart';
import 'package:zulors_shop_vendor/features/order/domain/models/order_model.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/helper/image_size_checker.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';

import '../../../main.dart';



class OrderedProductListItemWidget extends StatefulWidget {
  final OrderDetailsModel? orderDetailsModel;
  final String? paymentStatus;
  final OrderModel? orderModel;
  final int? orderId;
  final int? index;
  final int? length;
  const OrderedProductListItemWidget({super.key, this.orderDetailsModel, this.paymentStatus, this.orderModel, this.orderId, this.index, this.length});

  @override
  State<OrderedProductListItemWidget> createState() => _OrderedProductListItemWidgetState();
}

class _OrderedProductListItemWidgetState extends State<OrderedProductListItemWidget> {
  final ReceivePort _port = ReceivePort();


  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      setState((){ });
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }


  PlatformFile? fileNamed;
  File? file;
  int?  fileSize;
  DigitalVariation? digitalVariation;
  Variation? variation;
  @override
  Widget build(BuildContext context) {
    if(widget.orderDetailsModel!.productDetails != null && widget.orderDetailsModel!.variant != null && widget.orderDetailsModel!.variant!.isNotEmpty && widget.orderDetailsModel!.productDetails?.productType == 'digital') {
      for(DigitalVariation dv in widget.orderDetailsModel!.productDetails!.digitalVariation ?? []) {
        if(dv.variantKey == widget.orderDetailsModel!.variant){
          digitalVariation = dv;
        }
      }
    }

    if (widget.orderDetailsModel?.productDetails?.productType == 'physical' && widget.orderDetailsModel!.productDetails?.variation != null && widget.orderDetailsModel!.productDetails!.variation!.isNotEmpty) {
      for(Variation v in widget.orderDetailsModel!.productDetails!.variation ?? []) {
        if(v.type == widget.orderDetailsModel!.variant){
          variation = v;
        }
      }
    }

    return  widget.orderDetailsModel!.productDetails != null?
    Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: Container(decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
          border: Border.all(width: .5, color: Theme.of(context).primaryColor.withValues(alpha:.125))),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical:Dimensions.paddingSizeSmall),
        child: Column( children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [

            Stack(children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                  border: Border.all(width: .5, color: Theme.of(context).primaryColor.withValues(alpha:.125)),
                ),
                height: Dimensions.imageSize, width: Dimensions.imageSize,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CustomImageWidget(height: Dimensions.imageSize, width: Dimensions.imageSize,
                        image: '${widget.orderDetailsModel!.productDetails?.thumbnailFullUrl?.path}')
                ),
              ),

              if((widget.orderDetailsModel?.productDetails?.discount ?? 0) > 0 || widget.orderDetailsModel?.productDetails?.clearanceSale != null)
                Positioned(top: 10, left: 0, child: Container(height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(Dimensions.paddingSizeExtraSmall), bottomRight: Radius.circular(Dimensions.paddingSizeExtraSmall)),),

                  child: Center(
                    child: Text(widget.orderDetailsModel?.productDetails?.clearanceSale != null ?
                    PriceConverter.percentageCalculation(
                      context,
                      widget.orderDetailsModel?.productDetails?.unitPrice,
                      widget.orderDetailsModel?.productDetails?.clearanceSale?.discountAmount,
                      widget.orderDetailsModel?.productDetails?.clearanceSale?.discountType,
                    ) :
                    PriceConverter.percentageCalculation(
                      context,
                      widget.orderDetailsModel?.productDetails?.unitPrice,
                      widget.orderDetailsModel?.productDetails?.discount,
                      widget.orderDetailsModel?.productDetails?.discountType,
                    ), style: titilliumRegular.copyWith(
                      color: Theme.of(context).cardColor,
                      fontSize: Dimensions.fontSizeSmall,
                    )),
                  ),
                )),
            ]),
            const SizedBox(width: Dimensions.paddingSizeDefault),


            Expanded(
              child: Column(crossAxisAlignment:CrossAxisAlignment.start, children: [
                Text(widget.orderDetailsModel!.productDetails?.name??'',
                  style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  maxLines: 1, overflow: TextOverflow.ellipsis),



                Row( children: [
                  (widget.orderDetailsModel!.productDetails!.discount! > 0 &&
                      widget.orderDetailsModel!.productDetails!.discount!= null)?
                  Text(PriceConverter.convertPrice(context,
                      (widget.orderDetailsModel!.variant != null && widget.orderDetailsModel!.variant!.isNotEmpty && widget.orderDetailsModel!.productDetails?.productType == 'digital') ?
                      double.parse(digitalVariation!.price!.toString()) :
                      (widget.orderDetailsModel!.productDetails?.productType == 'physical' && widget.orderDetailsModel!.productDetails?.variation != null && widget.orderDetailsModel!.productDetails!.variation!.isNotEmpty) ?
                      variation?.price ?? 0
                          : widget.orderDetailsModel!.productDetails!.unitPrice!.toDouble()
                  ),
                    style: titilliumRegular.copyWith(color: Theme.of(context).colorScheme.error,fontSize: Dimensions.fontSizeSmall,
                        decoration: TextDecoration.lineThrough),):const SizedBox(),
                  SizedBox(width: widget.orderDetailsModel!.productDetails!.discount! > 0?
                  Dimensions.paddingSizeDefault : 0),



                  Text(PriceConverter.convertPrice(context,
                      (widget.orderDetailsModel!.variant != null && widget.orderDetailsModel!.variant!.isNotEmpty && widget.orderDetailsModel!.productDetails?.productType == 'digital') ?
                      double.parse(digitalVariation!.price!.toString()) :
                      (widget.orderDetailsModel!.productDetails?.productType == 'physical' && widget.orderDetailsModel!.productDetails?.variation != null && widget.orderDetailsModel!.productDetails!.variation!.isNotEmpty) ?
                      variation?.price ?? 0 :
                      widget.orderDetailsModel!.productDetails!.unitPrice!.toDouble(),
                      discount :widget.orderDetailsModel!.productDetails!.discount,
                      discountType :widget.orderDetailsModel!.productDetails!.discountType),
                    style: titilliumSemiBold.copyWith(color: Theme.of(context).primaryColor),),


                ],),

                // Padding(padding: const EdgeInsets.symmetric(vertical: 0.0),
                //     child: widget.orderDetailsModel!.productDetails!.taxModel == 'exclude'?
                //     Text('${getTranslated('tax', context)} ${PriceConverter.convertPrice(context, widget.orderDetailsModel!.tax)}',
                //         style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)):
                //     Text('${getTranslated('tax', context)} ${widget.orderDetailsModel!.productDetails!.taxModel}',
                //         style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color))),

                // const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                (widget.orderDetailsModel!.variant != null && widget.orderDetailsModel!.variant!.isNotEmpty) ?
                Padding(padding: const EdgeInsets.only(top: 0.0),
                  child: Text(widget.orderDetailsModel!.variant!,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).disabledColor,)),) : const SizedBox(),
                // const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Row(children: [
                  Text(getTranslated('qty', context)!,
                      style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)),

                  Text(': ${widget.orderDetailsModel!.qty}',
                      style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))]),

              ]),
            ),
          ]),


          SizedBox(height: widget.orderDetailsModel!.productDetails!.productType =='digital'?
          Dimensions.paddingSizeSmall : 0),
          widget.orderDetailsModel!.productDetails!.productType =='digital' ?
          Consumer<OrderDetailsController>(
              builder: (context, orderDetailsController, _) {
                return Row(mainAxisAlignment: MainAxisAlignment.end,crossAxisAlignment: CrossAxisAlignment.end, children: [
                  InkWell(onTap : () async {
                    if(widget.orderDetailsModel!.productDetails!.digitalProductType == 'ready_after_sell' &&
                        widget.orderDetailsModel!.digitalFileAfterSell == null ){
                      showCustomSnackBarWidget(getTranslated('product_not_uploaded_yet', context), context, isToaster: true);

                    }else{
                      _downloadProduct(widget.index!);
                    }

                  },
                    child:  Container(
                      height: 38,width: 120,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                          color: Theme.of(context).primaryColor
                      ),
                      alignment: Alignment.center,
                      child: (orderDetailsController.isDownloadLoading &&  orderDetailsController.downloadIndex == widget.index) ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white)) : Center(child: Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${getTranslated('download', context)}',
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Colors.white)),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          SizedBox(width: Dimensions.iconSizeDefault,
                              child: Image.asset(Images.download, color: Colors.white))
                        ],
                      )),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  widget.orderDetailsModel!.productDetails!.digitalProductType == 'ready_after_sell' ?
                  Expanded(
                    child: Column(children: [
                      InkWell(onTap: ()async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'zip', 'jpg', 'png', "jpeg", "gif"],
                        );

                        ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;

                        if (result != null) {
                          file = File(result.files.single.path!);
                          double fileSizeInMB = ImageSize.getFileSizeFromFile(file!);

                          if(fileSizeInMB > (configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)) {
                            if(context.mounted){
                              showCustomSnackBarWidget('${getTranslated('maximum_image_size', context)} ${(configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)}MB', context, sanckBarType: SnackBarType.warning);
                            }
                          } else {
                            fileSize = await file!.length();
                            fileNamed = result.files.first;
                            orderDetailsController.setSelectedFileName(file);
                          }
                        } else {

                        }
                      },
                        child: Builder(
                            builder: (context) {
                              return Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    widget.orderDetailsModel!.digitalFileAfterSell != null && fileNamed == null?
                                    Text(widget.orderDetailsModel!.digitalFileAfterSell!, maxLines: 2,overflow: TextOverflow.ellipsis,
                                        style: robotoRegular.copyWith()):
                                    Text(fileNamed != null? fileNamed?.name??'':'',maxLines: 2,overflow: TextOverflow.ellipsis,
                                        style: robotoRegular.copyWith()),
                                    fileNamed == null?
                                    Container(
                                      padding: const EdgeInsets.only(left: 5),
                                      height: 38,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                          color: Theme.of(context).colorScheme.onTertiaryContainer
                                      ),
                                      alignment: Alignment.center,
                                      child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('${getTranslated('choose_file', context)}',
                                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color:Colors.white),),
                                          const SizedBox(width: Dimensions.paddingSizeSmall),
                                          RotatedBox(
                                            quarterTurns:2,
                                            child: SizedBox(width: Dimensions.iconSizeDefault,
                                                child: Image.asset(Images.download, color : Colors.white)),
                                          )
                                        ],
                                      )),
                                    ):const SizedBox(),
                                  ]);
                            }
                        ),
                      ),

                      fileNamed != null?
                      InkWell(
                        onTap:(){
                          Provider.of<OrderDetailsController>(context, listen: false).uploadReadyAfterSellDigitalProduct(context, orderDetailsController.selectedFileForImport,
                              Provider.of<AuthController>(context, listen: false).getUserToken(), widget.orderDetailsModel!.id.toString());
                        },
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                            color: Theme.of(context).colorScheme.onTertiaryContainer,
                          ),
                          alignment: Alignment.center,
                          child: Center(child: orderDetailsController.isUploadLoading ?
                          SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Theme.of(context).cardColor)) :
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                            Text('${getTranslated('upload', context)}',
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).cardColor),),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            RotatedBox(
                              quarterTurns:2,
                              child: SizedBox(width: Dimensions.iconSizeDefault,
                                child: Image.asset(Images.downloadFile, color: Theme.of(context).cardColor),),
                            ),
                          ])),
                        ),
                      ) : const SizedBox(),
                    ]),
                  ) : const SizedBox()
                ]);
              }
          ) : const SizedBox(),


        ],
        ),
      ),
    ) : const SizedBox();
  }

  void _downloadProduct(int index ){
    String url = widget.orderDetailsModel!.productDetails!.digitalProductType == 'ready_after_sell'?
    '${widget.orderDetailsModel?.digitalFileAfterSellFullUrl?.path}':
    '${widget.orderDetailsModel?.productDetails?.digitalFileReadyFullUrl?.path}';

    String filename = widget.orderDetailsModel!.productDetails!.digitalProductType == 'ready_after_sell'?
    '${widget.orderDetailsModel?.digitalFileAfterSellFullUrl?.key}':
    '${widget.orderDetailsModel?.productDetails?.digitalFileReadyFullUrl?.key}';

    Provider.of<OrderDetailsController>(context, listen: false).productDownload(
        url: url,
        fileName: filename,
        index: index
    );
  }

}




