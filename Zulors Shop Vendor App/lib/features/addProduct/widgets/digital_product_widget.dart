import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/dropdown_decorator_widget.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/digital_product_controller.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/helper/image_size_checker.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_controller.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

import '../../../main.dart';



class DigitalProductWidget extends StatefulWidget {
  final AddProductController? resProvider;
  final Product? product;
  final bool fromAddProductNextScreen;
  const DigitalProductWidget({super.key, this.resProvider, this.product, this.fromAddProductNextScreen = false});

  @override
  State<DigitalProductWidget> createState() => _DigitalProductWidgetState();
}

class _DigitalProductWidgetState extends State<DigitalProductWidget> {
  PlatformFile? fileNamed;
  File? file;
  int?  fileSize;
  final List<String> itemList = ['physical', 'digital'];


  @override
  Widget build(BuildContext context) {

    return Column(children: [
      !widget.fromAddProductNextScreen ?
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
        child: DropdownDecoratorWidget(
            title: 'product_type',
            child: DropdownButton<String>(
              icon: const Icon(Icons.keyboard_arrow_down_outlined),
              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingEye)),
              value: widget.resProvider!.productTypeIndex == 0 ? 'physical' : 'digital',
              items: itemList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(getTranslated(value, context)!, style: robotoMedium),
                );
              }).toList(),
              onChanged: (value) {
                widget.resProvider!.setProductTypeIndex(value == 'physical' ? 0 : 1, true);
              },
              isExpanded: true,
              underline: const SizedBox(),
            )),
      ) : const SizedBox(),

      !widget.fromAddProductNextScreen ?
      SizedBox(height: widget.resProvider!.productTypeIndex == 1? Dimensions.paddingSizeSmall : 0) : const SizedBox(),


      widget.fromAddProductNextScreen && widget.resProvider!.productTypeIndex == 1 && Provider.of<DigitalProductController>(context,listen: false).digitalProductTypeIndex == 1?
      Consumer<DigitalProductController>(
        builder: (context, digitalProductController, child){
          return Padding(
            padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, 0),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
              ),
              child: InkWell(
                splashColor: Colors.transparent,
                onTap: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'zip', 'jpg', 'png', "jpeg", "gif"],
                  );
                  if (result != null) {
                    double value =   ImageSize.getFileSizeFromFile(File(result.files.single.path!));

                    ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;

                    if(value >  (configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)) {
                      showCustomSnackBarWidget('${getTranslated('maximum_image_size', Get.context!)} ${(configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)}MB', Get.context!, sanckBarType: SnackBarType.warning);
                    } else {
                      file = File(result.files.single.path!);
                      fileSize = await file!.length();
                      fileNamed = result.files.first;
                      digitalProductController.setSelectedFileName(file);
                    }
                  }
                },
                child: Builder(
                    builder: (context) {
                      return Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 50,child: Image.asset(Images.upload)),
                          digitalProductController.selectedFileForImport !=null ?
                          Text(fileNamed != null? fileNamed?.name??'':'${widget.product?.digitalFileReady}',maxLines: 2,overflow: TextOverflow.ellipsis) :
                          Text(getTranslated('upload_file', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),

                          widget.product !=null && fileNamed == null ?
                          Text(widget.product!.digitalFileReady??'', style: robotoRegular.copyWith()):const SizedBox(),

                        ],);
                    }
                ),
              ),
            ),
          );
        }
      ):const SizedBox(),

      widget.fromAddProductNextScreen ?
      const SizedBox(height: Dimensions.paddingSizeDefault) : const SizedBox(),

    ]);
  }
}
