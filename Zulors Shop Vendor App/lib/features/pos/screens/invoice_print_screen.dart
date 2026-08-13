import 'dart:async';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/invoice_model.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/invoice_dialog_widget.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/shop_model.dart';
import 'package:zulors_shop_vendor/localization/controllers/localization_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';


class InVoicePrintScreen extends StatefulWidget {
  final InvoiceModel? invoice;
  final ShopModel? shopModel;
  final int? orderId;
  final double? discountProduct;
  final double? couponDiscountProduct;
  final double? extraDiscountAmount;
  final double? tax;
  final double? total;
  const InVoicePrintScreen({super.key, this.invoice, this.shopModel, this.orderId, this.discountProduct, this.total, this.couponDiscountProduct, this.tax, this.extraDiscountAmount});

  @override
  State<InVoicePrintScreen> createState() => _InVoicePrintScreenState();
}

class _InVoicePrintScreenState extends State<InVoicePrintScreen> {

  bool connected = false;
  List<BluetoothInfo>? availableBluetoothDevices;
  bool _isLoading = false;
  final List<int> _paperSizeList = [80, 58];
  int _selectedSize = 80;
  ScreenshotController screenshotController = ScreenshotController();
  String? _warningMessage;
  bool _printLoading = false;

  Future<void> getBluetooth() async {
    setState(() {
      _isLoading = true;
    });

    final List<BluetoothInfo> bluetoothDevices = await PrintBluetoothThermal.pairedBluetooths;
    if (kDebugMode) {
      print("Bluetooth list: $bluetoothDevices");
    }
    connected = await PrintBluetoothThermal.connectionStatus;

    if(!connected) {
      _warningMessage = null;
      Provider.of<CartController>(Get.context!, listen: false).setBluetoothMacAddress('');
    } else {
      _warningMessage =  getTranslated('please_enable_your_location_and_bluetooth_in_your_system',  Get.context!)!;
    }

    setState(() {
      availableBluetoothDevices = bluetoothDevices;
      _isLoading = false;
    });

  }

  Future<void> setConnect(String mac) async {
    final bool result = await PrintBluetoothThermal.connect(macPrinterAddress: mac);

    if (result) {
      setState(() {
        connected = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    getBluetooth();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// method to scan devices according PrinterType
  Future _printReceipt(Uint8List screenshot) async {
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (connectionStatus) {
      List<int> ticket = await testTicket(screenshot);
      final result = await PrintBluetoothThermal.writeBytes(ticket);
      if (kDebugMode) {
        print("print result: $result");
      }
    } else {
      showCustomSnackBarWidget(getTranslated('no_thermal_printer_connected',  Get.context!,)!, Get.context!, sanckBarType: SnackBarType.warning);
    }
    setState(() {
      _printLoading = false;
    });
  }

  Future<List<int>> testTicket(Uint8List screenshot) async {
    List<int> bytes = [];
    final img.Image? image = img.decodeImage(screenshot);
    img.Image resized = img.copyResize(image!, width: _selectedSize == 80 ? 500 : 365);
    final profile = await CapabilityProfile.load();
    final generator = Generator(_selectedSize == 80 ? PaperSize.mm80 : PaperSize.mm58, profile);

    // Using `ESC *`
    bytes += generator.image(resized);

    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Text(getTranslated('paired_bluetooth',  Get.context!,)!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                SizedBox(height: 20, width: 20,
                  child: _isLoading ?  CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ) : InkWell(
                    onTap: () => getBluetooth(),
                    child: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
                  ),
                ),
              ]),

              SizedBox(width: 100, child: DropdownButton<int>(
                hint: Text(getTranslated('select',  Get.context!)!),
                value: _selectedSize,
                items: _paperSizeList.map((int? value) {
                  return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value''mm'));
                }).toList(),
                onChanged: (int? value) {
                  setState(() {
                    _selectedSize = value!;
                  });
                },
                isExpanded: true, underline: const SizedBox(),
              )),

            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(children: [
              availableBluetoothDevices != null && (availableBluetoothDevices?.length ?? 0) > 0 ? ListView.builder(
                itemCount: availableBluetoothDevices?.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Consumer<CartController>(
                      builder:(context, cartController, child){
                      bool isConnected = connected &&  availableBluetoothDevices![index].macAdress == cartController.getBluetoothMacAddress();

                      return Stack(children: [

                        ListTile(
                          selected: isConnected,
                          onTap: () {
                            if(availableBluetoothDevices?[index].macAdress.isNotEmpty ?? false) {
                              if(!connected) {
                                cartController.setBluetoothMacAddress(availableBluetoothDevices?[index].macAdress);
                              }
                              setConnect(availableBluetoothDevices?[index].macAdress ?? '');
                            }
                          },
                          title: Text(availableBluetoothDevices?[index].name ?? ''),
                          subtitle: Text(
                            isConnected ? getTranslated('connected',  Get.context!)! :  getTranslated('click_to_connect',  Get.context!)!,
                            style: robotoRegular.copyWith(color: isConnected ? null : Theme.of(context).primaryColor),
                          ),
                        ),

                        if(availableBluetoothDevices?[index].macAdress == cartController.getBluetoothMacAddress())
                          Positioned.fill(
                            child: Align(alignment: Provider.of<LocalizationController>(Get.context!, listen: false).isLtr ? Alignment.centerRight : Alignment.centerLeft, child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeExtraSmall,
                                horizontal: Dimensions.paddingSizeLarge,
                              ),
                              child: Icon(Icons.check_circle_outline_outlined, color: Theme.of(context).primaryColor,),
                            )),
                          ),
                        ],
                      );
                    }
                );
              }) : Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Text(
                  _warningMessage?? '',
                  style: robotoRegular.copyWith(color: Colors.redAccent),
                ),
              ),

              InvoiceDialogWidget(
                shopModel: widget.shopModel, orderId: widget.orderId, invoice: widget.invoice,
                discountProduct: widget.discountProduct, total: widget.total, couponDiscountProduct: widget.couponDiscountProduct,
                extraDiscountAmount: widget.extraDiscountAmount,
                tax: widget.tax, screenshotController: screenshotController,
              ),
            ]),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: CustomButtonWidget(
            btnTxt: _printLoading ? getTranslated('printing',  Get.context!)! : getTranslated('print_invoice',  Get.context!)!,
            // height: 40,
            // margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
            onTap : _printLoading ? null : () {
              setState(() {
                _printLoading = true;
              });
              screenshotController.capture(delay: const Duration(milliseconds: 10)).then((Uint8List? capturedImage) {
                //Capture Done
                if (kDebugMode) {
                  print('its calling :  $capturedImage');
                }
                _printReceipt(capturedImage!);

              }).catchError((onError) {
                if (kDebugMode) {
                  print(onError);
                }
              });
            },
          ),
        ),

      ],
    );
  }
}