import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/profile/controllers/profile_controller.dart';
import 'package:zulors_shop_vendor/features/profile/domain/models/withdraw_model.dart';
import 'package:zulors_shop_vendor/features/shop/controllers/shop_controller.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/payment_information_model.dart';
import 'package:zulors_shop_vendor/features/transaction/controllers/transaction_controller.dart';
import 'package:zulors_shop_vendor/features/wallet/domain/services/wallet_service_interface.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';

class WalletController with ChangeNotifier{

  final WalletServiceInterface walletServiceInterface;
  WalletController({required this.walletServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  WithdrawModel? withdrawModel;
  List<WithdrawModel> methodList = [];
  MethodModel? methodSelected;
  List<MethodModel?> methodsIds = [];
  List<MethodModel?> myMethodsIds = [];

  List<String> inputValueList = [];
  bool validityCheck = false;

  PaymentInformationModel ? _paymentInformationModel;
  PaymentInformationModel ? get paymentInformationModel => _paymentInformationModel;




  void setTitle(int index, String title) {
    inputFieldControllerList[index].text = title;
  }


  List<TextEditingController> inputFieldControllerList = [];
  void getInputFieldList(){
    inputFieldControllerList = [];
    if(methodList.isNotEmpty){
      for(int i= 0; i< (methodSelected?.methodFields?.length ?? 0 ) ; i++){
        inputFieldControllerList.add(TextEditingController());
      }
    }
  }

  List <String?> keyList = [];


  void setMethodTypeIndex(MethodModel? index, {bool notify = true}) {
    methodSelected = index;

    keyList = [];
    if(methodList.isNotEmpty){
      for(int i= 0; i< (methodSelected?.methodFields?.length ?? 0) ; i++){
        keyList.add(methodSelected?.methodFields![i].inputName);
      }
      getInputFieldList();
    }
    if(notify){
      notifyListeners();
    }
  }


  Future<void> getWithdrawMethods(BuildContext context) async{
    methodList = [];
    methodsIds = [];
    ApiResponse response = await walletServiceInterface.getDynamicWithDrawMethod();
      response.response!.data.forEach((method) => methodList.add(WithdrawModel.fromJson(method)));
      getInputFieldList();
      for(int index = 0; index < methodList.length; index++) {
        methodsIds.add(
          MethodModel(
            id: methodList[index].id,
            inputName: methodList[index].methodName,
            type: 'other',
            methodFields: methodList[index].methodFields
          )
        );
      }
    notifyListeners();
  }



  void checkValidity(){
    for(int i= 0; i< inputValueList.length; i++){
      if(inputValueList[i].isEmpty){
        inputValueList.clear();
        validityCheck = true;
        notifyListeners();
      }
    }

  }


  Future<ApiResponse> updateBalance(String balance, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    if(methodSelected?.type == 'other') {
      for(TextEditingController textEditingController in inputFieldControllerList) {
        inputValueList.add(textEditingController.text.trim());
      }
    } else if(methodSelected?.type == 'my_methods') {
      inputValueList = [];
      keyList = [];

      methodSelected?.methodInfo?.forEach((key, value) {
        keyList.add(key);
        inputValueList.add(value);
      });
    }


    ApiResponse apiResponse = await walletServiceInterface.withdrawBalance(keyList, inputValueList, methodSelected?.id, balance);
    if(Provider.of<ShopController>(Get.context!, listen: false).shopModel?.setupGuideApp != null && Provider.of<ShopController>(Get.context!, listen: false).shopModel?.setupGuideApp?['withdraw_setup'] != 1) {
      Provider.of<ShopController>(Get.context!, listen: false).updateTutorialFlow('withdraw_setup');
      Provider.of<ShopController>(Get.context!, listen: false).updateSetupGuideApp('withdraw_setup', 1);
    }

      inputValueList.clear();
      inputFieldControllerList.clear();
      Provider.of<TransactionController>(Get.context!, listen: false).getTransactionList(Get.context!,'all','','');
      Provider.of<ProfileController>(Get.context!, listen: false).getSellerInfo();
      _isLoading = false;
      notifyListeners();
      showCustomSnackBarWidget(getTranslated('withdraw_request_sent_successfully', Get.context!), Get.context!, isToaster: true, isError: false);
      Navigator.pop(Get.context!);
    return apiResponse;
  }



  Future<void> getPaymentInfoList() async {
    ApiResponse apiResponse = await walletServiceInterface.getPaymentInfoList();
    myMethodsIds = [];
    if(apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _paymentInformationModel = PaymentInformationModel.fromJson(apiResponse.response?.data);

      for(int index = 0; index < (_paymentInformationModel?.data?.length ?? 0) ; index++) {
        myMethodsIds.add(
          MethodModel(
            id: _paymentInformationModel?.data?[index].withdrawMethodId,
            inputName: _paymentInformationModel?.data?[index].methodName,
            type: 'my_methods',
            methodFields: _paymentInformationModel?.data?[index].withdrawMethod?.methodFields,
            methodInfo: _paymentInformationModel?.data?[index].methodInfo,
            isDefault: _paymentInformationModel?.data?[index].isDefault ?? false,
          )
        );
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }


  void setDefaultPaymentMethod () {
    if(methodSelected == null || (!(methodSelected?.isDefault ?? false) && myMethodsIds.isNotEmpty)) {
      for(MethodModel? paymentInfo in myMethodsIds) {
        if(paymentInfo?.isDefault ?? false) {
          setMethodTypeIndex(
            paymentInfo,
            notify: false,
          );
        }
      }
    } else if (methodSelected == null && methodsIds.isNotEmpty) {
      setMethodTypeIndex(
        methodsIds.first,
        notify: false,
      );
    }
  }



  Future<ApiResponse> closeWithdrawRequest(int id, String balance) async {
    _isLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await walletServiceInterface.closeWithdrawRequest(id, balance);
    if(apiResponse.response?.statusCode == 200) {
      Provider.of<ProfileController>(Get.context!, listen: false).updateWalletAmount(balance);
      Provider.of<ShopController>(Get.context!, listen: false).getShopInfo();
    }
    _isLoading = false;
    notifyListeners();
    return apiResponse;
  }

}