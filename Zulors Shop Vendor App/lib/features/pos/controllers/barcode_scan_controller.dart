import 'package:barcode_scan2/gen/protos/protos.pbenum.dart';
import 'package:barcode_scan2/model/android_options.dart';
import 'package:barcode_scan2/model/scan_options.dart';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/cart_model.dart';
import 'package:zulors_shop_vendor/features/pos/domain/services/cart_service_interface.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/product_variation_selection_dialog_widget.dart';
import 'package:zulors_shop_vendor/features/product/controllers/product_controller.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';



class BarcodeScanController extends ChangeNotifier{
  final CartServiceInterface cartServiceInterface;
  BarcodeScanController({required this.cartServiceInterface});


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Product? _scanProduct ;
  Product? get scanProduct=>_scanProduct;



  Future<void> scanProductBarCode(BuildContext context) async{
    String? scannedProductBarCode;
    try{
      final result = await BarcodeScanner.scan(
        options: const ScanOptions(
          strings: {
            'cancel': 'cancel',
            'flash_on': 'flash on',
            'flash_off': 'flash off',
          },
          restrictFormat: [BarcodeFormat.code128],
          useCamera: -1,
          autoEnableFlash: false,
          android: AndroidOptions(
            aspectTolerance: 0.00,
            useAutoFocus: true,
          ),
        ),
      );
      scannedProductBarCode = result.rawContent;
    }
    on PlatformException{
      if (kDebugMode) {
        print('object');
      }
    }
    getProductFromScan(Get.context!, scannedProductBarCode);
  }


  Future<void> getProductFromScan(BuildContext context, String? productCode) async {
    _isLoading = true;
    ApiResponse response = await cartServiceInterface.getProductFromScan(productCode);

    if(response.response!.statusCode == 200) {
      _scanProduct = Product.fromJson(response.response!.data);
      Provider.of<ProductController>(Get.context!, listen: false).initData(_scanProduct!,1, Get.context!);
      if(scanProduct!.variation!.isNotEmpty || scanProduct!.digitalProductFileTypes!.isNotEmpty){
        showModalBottomSheet(context: Get.context!, isScrollControlled: true,
            backgroundColor: Theme.of(Get.context!).primaryColor.withValues(alpha:0),
            builder: (con) => CartBottomSheetWidget(product: _scanProduct, callback: () {
              showCustomSnackBarWidget(getTranslated('added_to_cart', context), context, isError: false);},));

      } else{
        CartModel cartModel = CartModel(_scanProduct!.unitPrice, _scanProduct!.discount, 1, _scanProduct!.tax, null,null,null,null, _scanProduct, _scanProduct!.taxModel);
        Provider.of<CartController>(Get.context!, listen: false).addToCart(Get.context!, cartModel);
      }

      _isLoading = false;
    }else {
      ApiChecker.checkApi( response);
    }
    _isLoading = false;
    notifyListeners();
  }

}