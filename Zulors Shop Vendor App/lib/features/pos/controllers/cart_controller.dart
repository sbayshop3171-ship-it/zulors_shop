import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/customer_controller.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/customer_body.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/invoice_model.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/place_order_body.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/cart_model.dart';
import 'package:zulors_shop_vendor/features/pos/domain/services/cart_service_interface.dart';
import 'package:zulors_shop_vendor/features/pos/screens/pos_screen.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/temporary_cart_for_customer_model.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:zulors_shop_vendor/helper/debounce_helper.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/features/order/controllers/order_controller.dart';
import 'package:zulors_shop_vendor/features/pos/screens/invoice_screen.dart';

class CartController extends ChangeNotifier{
  final CartServiceInterface cartServiceInterface;
  CartController({required this.cartServiceInterface});


  List<CartModel> _cartList = [];
  List<CartModel> get cartList => _cartList;
  double _amount = 0.0;
  double get amount => _amount;
  double _productDiscount = 0.0;
  double get productDiscount => _productDiscount;

  final double _productTax = 0.0;
  double get productTax => _productTax;
  InvoiceModel? _invoice;
  InvoiceModel? get invoice => _invoice;

  // TemporaryCartListModel(),

  List<TemporaryCartListModel> _customerCartList = [];
  List<TemporaryCartListModel> get customerCartList => _customerCartList;

  TemporaryCartListModel? _currentCartModel;
  TemporaryCartListModel? get currentCartModel => _currentCartModel;

  double _discountOnProduct = 0;
  double get discountOnProduct => _discountOnProduct;

  double _totalTaxAmount = 0;
  double get totalTaxAmount => _totalTaxAmount;

  bool _isPaidAmountLess = true;
  bool get isPaidAmountLess => _isPaidAmountLess;

  bool _isUpdatePaidAmount = true;
  bool get updatePaidAmount => _isUpdatePaidAmount;

  final TextEditingController _collectedCashController = TextEditingController();
  TextEditingController get collectedCashController => _collectedCashController;

  final TextEditingController _customerWalletController = TextEditingController();
  TextEditingController get customerWalletController => _customerWalletController;

  final TextEditingController _extraDiscountController = TextEditingController();
  TextEditingController get extraDiscountController => _extraDiscountController;

  double _returnToCustomerAmount = 0 ;
  double get returnToCustomerAmount => _returnToCustomerAmount;

  double? _couponCodeAmount = 0;
  double? get couponCodeAmount =>_couponCodeAmount;

  double _extraDiscountAmount = 0;
  double get extraDiscountAmount =>_extraDiscountAmount;

  int _discountTypeIndex = 0;
  int get discountTypeIndex => _discountTypeIndex;


  String? _selectedDiscountType = '';
  String? get selectedDiscountType => _selectedDiscountType;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<bool> _isSelectedList = [];
  List<bool> get isSelectedList => _isSelectedList;

  List<int?> _customerIds = [0];
  List<int?> get customerIds => _customerIds;

  List<CartModel>? _existInCartList;
  List<CartModel>? get existInCartList =>_existInCartList;

  final TextEditingController _searchCustomerController = TextEditingController();
  TextEditingController get searchCustomerController => _searchCustomerController;


  double _customerBalance = 0.0;
  double get customerBalance=> _customerBalance;
  int cartIndex = 0;

  PlaceOrderBody? modifiedCart;

  final DebounceHelper _debounce = DebounceHelper(milliseconds: 500);


  int _paymentTypeIndex = 0;
  int get paymentTypeIndex => _paymentTypeIndex;
  void setPaymentTypeIndex(int index, bool notify) {
    _paymentTypeIndex = index;
    if(notify) {
      notifyListeners();
    }
  }



  void applyCouponCodeAndExtraDiscount(BuildContext context, double payable) {
    _extraDiscountAmount = 0;
    String extraDiscount = _extraDiscountController.text.trim();
    _extraDiscountAmount = double.parse(extraDiscount);

    double extraDiscountPercent = double.parse(PriceConverter.discountCalculationWithOutSymbol(context, amount, _extraDiscountAmount, _selectedDiscountType));

    if(_selectedDiscountType == 'percent' ?
    extraDiscountPercent > double.tryParse(PriceConverter.convertPriceWithoutSymbol(Get.context!, payable))! :
    _extraDiscountAmount >  double.tryParse(PriceConverter.convertPriceWithoutSymbol(Get.context!, payable))!
    ) {
      showCustomSnackBarWidget(getTranslated('discount_cant_greater_than_order_amount', Get.context!), Get.context!, sanckBarType: SnackBarType.warning, isToaster: true, );
    }else{
      _currentCartModel?.extraDiscount = _extraDiscountAmount;
      showCustomSnackBarWidget(getTranslated('extra_discount_added_successfully', Get.context!), Get.context!, isToaster: true, isError: false);
    }
    notifyListeners();
  }

  void addToCart(BuildContext context, CartModel cartModel, {bool decreaseQuantity= false, bool updateToCart = false}) {

    _amount = 0;

    if(_currentCartModel != null) {
      _currentCartModel?.couponAmount = 0;
      _currentCartModel?.extraDiscount = 0;
      _extraDiscountController.text = '';
      _extraDiscountAmount = 0;
    }


    bool exists = _currentCartModel!.cart!.any((cart) {
      return cart.product!.id == cartModel.product!.id &&
          ((cartModel.varientKey == null && cart.variant == cartModel.variant) ||
              (cartModel.varientKey != null && cart.varientKey == cartModel.varientKey));
    });


    if(exists && updateToCart) {
      updateCart(context, cartModel);
      _debounce.run(() {
        getTaxAmount();
      });
    } else if (exists) {
      isExistInCart(context, cartModel, decreaseQuantity: decreaseQuantity);
      _debounce.run(() {
        getTaxAmount();
      });
    } else {
      _currentCartModel!.cart!.add(cartModel);
      calculateTotalAmount();
      _debounce.run(() {
        getTaxAmount();
      });
      showCustomSnackBarWidget(getTranslated('added_cart_successfully', context),context ,isToaster: true, isError: false);
    }
    notifyListeners();

  }




  void calculateHoldOrderPrice() {
    calculateTotalAmount();
    _isUpdatePaidAmount = true;
    notifyListeners();
  }

  void calculateTotalAmount() {
    _amount = 0;
    if(_currentCartModel?.cart != null && _currentCartModel!.cart!.isNotEmpty) {
      for(int i = 0; i< _currentCartModel!.cart!.length; i++) {
        int? quantity = _currentCartModel!.cart![i].quantity!;
        double unitPrice =  0;
        double includeTax = 0;

        if(_currentCartModel!.cart![i].variation != null) {
          unitPrice = _currentCartModel?.cart?[i].variation?.price ?? 0;
        } else if (_currentCartModel?.cart?[i].varientKey != null) {
          unitPrice = _currentCartModel?.cart?[i].digitalVariationPrice ?? 0;
        } else {
          unitPrice = _currentCartModel?.cart?[i].price ?? 0;
        }

        if (_currentCartModel?.cart?[i].product?.taxModel == "include") {
          includeTax = calculateIncludedTax(unitPrice * quantity, _currentCartModel?.cart?[i].product?.tax ?? 0);
        }

        _amount += (unitPrice * quantity) - includeTax;
      }
    }
  }




  double calculateIncludedTax(double totalPrice, double taxRate) {
    return (totalPrice * taxRate) / 100;
  }



  void setQuantity(BuildContext context, bool isIncrement, int? index, {bool showToaster = false}) {
    if(_currentCartModel != null) {
      _currentCartModel?.couponAmount = 0;
      _currentCartModel?.extraDiscount = 0;
      _extraDiscountController.text = '';
      _extraDiscountAmount = 0;
    }

    if (isIncrement) {
      if(_currentCartModel!.cart![index!].product!.currentStock! > _currentCartModel!.cart![index].quantity! && _currentCartModel!.cart![index].product!.productType == 'physical')
      {
        _amount = 0;
        _currentCartModel!.cart![index].quantity = _currentCartModel!.cart![index].quantity! + 1;

        calculateTotalAmount();
        if(showToaster){
          showCustomSnackBarWidget(getTranslated('quantity_updated', context), context, isToaster: true, isError: false);
        }

      }else if(_currentCartModel!.cart![index].product!.productType == 'digital')
      {
        _amount = 0;
        _currentCartModel!.cart![index].quantity = _currentCartModel!.cart![index].quantity! + 1;

        if(showToaster){
          showCustomSnackBarWidget(getTranslated('quantity_updated', context), context, isToaster: true, isError: false);
        }

        calculateTotalAmount();
      }else{
        showCustomSnackBarWidget(getTranslated('stock_out', context), context, isToaster: true);
      }
    } else {
      _amount = 0;
      if(_currentCartModel!.cart![index!].quantity! > 1){
        showCustomSnackBarWidget(getTranslated('quantity_updated', context), context, isToaster: true, isError: false);
        _currentCartModel!.cart![index].quantity = _currentCartModel!.cart![index].quantity! - 1;

        calculateTotalAmount();
      }else{
        showCustomSnackBarWidget(getTranslated('minimum_quantity_1', context), context, isToaster: true);

        calculateTotalAmount();
      }
    }
    notifyListeners();
  }

  void removeFromCart(int index) {
    CartModel cartItem = _currentCartModel!.cart![index];
    int? quantity = _currentCartModel!.cart![index].quantity!;

    double cartItemPrice = calculateBaseAmount(cartItem, quantity);

    if (cartItem.product!.taxModel == "include") {
      final includedTax = calculateIncludedTax(cartItemPrice, cartItem.product!.tax!);
      cartItemPrice -= includedTax;
    }

    _amount -= cartItemPrice;

    if(_currentCartModel != null) {
      _currentCartModel!.couponAmount = 0;
      _currentCartModel!.extraDiscount = 0;
      _extraDiscountController.text = '';
      _extraDiscountAmount = 0;
    }
    _currentCartModel!.cart!.removeAt(index);
    _couponCodeAmount = 0;
    notifyListeners();
  }

  double calculateBaseAmount(CartModel cartItem, int quantity) {
    if (cartItem.variation != null) {
      return cartItem.variation!.price! * quantity;
    } else if (cartItem.varientKey != null) {
      return cartItem.digitalVariationPrice! * quantity;
    } else {
      return cartItem.price! * quantity;
    }
  }

  void removeAllCartList() {
    _cartList =[];
    _customerWalletController.clear();
    _extraDiscountAmount = 0;
    _amount = 0;
    _collectedCashController.clear();
    _customerCartList =[];
    _customerIds = [];
    searchCustomerController.text = 'Walk-In Customer';

    Provider.of<CustomerController>(Get.context!, listen: false).setCustomerInfo(0,  'Walk-In Customer', '', true, 0);
    notifyListeners();
  }



  void updateCart(BuildContext context,CartModel cartModel) {
    String variantKey = getVariantKey(cartModel);

    for(int index = 0; index < (_currentCartModel?.cart?.length ?? 0); index++) {
      if(_currentCartModel?.cart![index].product!.id == cartModel.product!.id && (variantKey != '' ? variantKey == getVariantKey(_currentCartModel!.cart![index]) : true)) {
        _currentCartModel!.cart![index] = cartModel;
      }
    }
  }


  bool isExistInCart(BuildContext context,CartModel cartModel, {bool decreaseQuantity= false}) {
    cartIndex = 0;

    String variantKey = getVariantKey(cartModel);

    for(int index = 0; index < (_currentCartModel?.cart?.length ?? 0); index++) {
      if(_currentCartModel?.cart![index].product!.id == cartModel.product!.id && (variantKey != '' ? variantKey == getVariantKey(_currentCartModel!.cart![index]) : true)) {
        if(decreaseQuantity){
          setQuantity(context, false, index);
          showCustomSnackBarWidget('1 ${getTranslated('item', context)} ${getTranslated('remove_from_cart_successfully', context)}',context, isToaster: true, isError: false);
        }else{
          setQuantity(context, true, index);
          showCustomSnackBarWidget('${getTranslated('added_cart_successfully', context)} ${ _currentCartModel?.cart![index].quantity} ${getTranslated('items', context)}',context, isToaster: true, isError: false);
        }
      }
    }
    return false;
  }

  String getVariantKey(CartModel cartModel) {
    String variantKey = '';

    if (cartModel.variant != null && cartModel.variant != '') {
      return cartModel.variant!;
    } else if (cartModel.varientKey != null && cartModel.varientKey != '') {
      return cartModel.varientKey!;
    }
    return variantKey;
  }


  void setExtraDiscountAmount(double? extraDiscountAmount, {bool isUpdate = true}) {
    _currentCartModel?.extraDiscount = extraDiscountAmount;
    _extraDiscountAmount = extraDiscountAmount ?? 0;
    _isUpdatePaidAmount = true;
    if(isUpdate) {
      notifyListeners();
    }
  }

  void setCouponCodeAndAmount(double? couponAmount, String? couponCode, {bool isUpdate = true}) {
    _couponCodeAmount = couponAmount;
    _currentCartModel?.couponAmount = couponAmount;
    _currentCartModel?.couponCode = couponCode;
    if(isUpdate) {
      notifyListeners();
    }
  }


  void clearCardForCancel(){
    _couponCodeAmount = 0;
    _extraDiscountAmount = 0;
  }

  Future<ApiResponse> placeOrder(BuildContext context, PlaceOrderBody placeOrderBody) async {
    _isLoading = true;
    notifyListeners();

    ApiResponse response = await cartServiceInterface.placeOrder(placeOrderBody);

    if(response.response?.statusCode == 200 && response.response?.data['checkProductTypeForWalkingCustomer'] == true) {
      showCustomSnackBarWidget(response.response?.data['message'], Get.context!, isToaster: true, isError: false, sanckBarType: SnackBarType.error);
      _isLoading = false;
    } else if(response.response!.statusCode == 200) {
      _isLoading = false;
      _couponCodeAmount = 0;
      _productDiscount = 0;
      _customerBalance = 0;
      _customerWalletController.clear();
      Provider.of<OrderController>(Get.context!, listen: false).getOrderList(Get.context!, 1,'all');
      showCustomSnackBarWidget(getTranslated('order_placed_successfully', Get.context!), Get.context!, isToaster: true, isError: false);
      _extraDiscountAmount = 0;
      _extraDiscountController.text = '';
      _extraDiscountAmount = 0;
      _amount = 0;
      _collectedCashController.clear();

      _extraDiscountAmount = 0;

      resetUserCard();
      saveCardData();

      _isUpdatePaidAmount = true;
      Provider.of<CustomerController>(Get.context!, listen: false).setCustomerInfo( 0,  'Walk-In Customer', '', true, 0);
      searchCustomerController.text = 'Walk-In Customer';
      if(_customerIds.isNotEmpty) {
        _amount = 0;

      }
      Navigator.push(Get.context!, MaterialPageRoute(builder: (_)=> InVoiceScreen(orderId: response.response!.data['order_id'])));

    }else{
      ApiChecker.checkApi( response);
    }
    notifyListeners();
    return response;
  }


  void setCurrentCartCustomerInfo(int? id, String? name, String? phone, double? customerBalance, bool notify) {
    _currentCartModel?.userId = id;
    _currentCartModel?.customerName = name;
    _currentCartModel?.phoneNumber = phone;
    _currentCartModel?.customerBalance = customerBalance;

    _paymentTypeIndex = 0;

    if(notify) {
      notifyListeners();
    }
  }

  void addToHoldUserList() {
    TemporaryCartListModel userCart = _currentCartModel!;

    if(userCart.userIndex != null && userCart.userIndex != 0 && isUserExists(userCart.userId!)) {
      updateHoldUser(userCart);
    } else if (userCart.userId == 0) {
      int randomNumber = Random().nextInt(10000);
      userCart.userId = randomNumber;
      userCart.customerName = '${userCart.customerName}-$randomNumber';
      addUserCart(userCart);
    } else {
      addUserCart(userCart);
    }
  }

  void addUserCart(TemporaryCartListModel userCart) {
    final rng = Random();
    userCart.userIndex = rng.nextInt(10000);
    _customerCartList.add(userCart);
    resetUserCard();
    saveCardData();
  }

  void updateHoldUser(TemporaryCartListModel userCart) {
    if(isUserExists(userCart.userId!)) {
      int index = getCartIndexByUserId(userCart.userId!);
      _customerCartList[index] = userCart;
      resetUserCard();
      saveCardData();
    }
  }

  void resumeHoldOrder(TemporaryCartListModel userCart, int index) {
    TemporaryCartListModel tempCart = userCart;

    removeCartItem(index);
    resetUserCard();
    saveCardData();


    Provider.of<CustomerController>(Get.context!, listen: false).setCustomerInfo( (tempCart.customerName?.contains('walk.ing') ?? false) ? 0 : tempCart.userId, tempCart.customerName, tempCart.phoneNumber, true, 0);
    _currentCartModel = tempCart;

    notifyListeners();
    calculateHoldOrderPrice();
  }

  void removeCartItem(int index) {
    _customerCartList.removeAt(index);
    notifyListeners();
  }

  void resetUserCard () {
     _currentCartModel = TemporaryCartListModel(
      userId: 0,
      customerName: 'Walk-In Customer',
      phoneNumber: '',
      cart: []
    );

    notifyListeners();
  }

  bool isUserExists(int userId) {
    for (int i = 1; i < _customerCartList.length; i++) {
      if (_customerCartList[i].userId == userId) {
        return true;
      }
    }
    return false;
  }


  TemporaryCartListModel getCartByUserId(int userId) {
    for (int i = 0; i < _customerCartList.length; i++) {
      if (_customerCartList[i].userId == userId) {
        return _customerCartList[i];
      }
    }
    throw Exception("Cart not found for user ID: $userId");
  }

  int getCartIndexByUserId(int userId) {
    for (int i = 0; i < _customerCartList.length; i++) {
      if (_customerCartList[i].userId == userId) {
        return i;
      }
    }
    throw Exception("Cart not found for user ID: $userId");
  }


  void saveCardData() async {
    cartServiceInterface.addToCartList(_customerCartList);
  }

  void getCartData() {
    List<TemporaryCartListModel> localCartList = cartServiceInterface.getCartList();

    if(localCartList.isNotEmpty) {
      _customerCartList = cartServiceInterface.getCartList();
    }
  }


  Future<void> addNewCustomer(BuildContext context, CustomerBody customerBody) async {
    _isLoading = true;
    notifyListeners();

    ApiResponse response = await cartServiceInterface.addNewCustomer(customerBody);

    if(response.error == 'The email has already been taken.' || response.error == 'The phone has already been taken.') {
      showCustomSnackBarWidget(response.error, Get.context!, isError: true, sanckBarType: SnackBarType.warning);
      _isLoading = false;
      notifyListeners();
    } else if(response.response!.statusCode == 200) {
      /// ToDo: get form cosutomer controller
     //  getCustomerList("all");
      _isLoading = false;
      Navigator.pop(Get.context!);
      Map map = response.response!.data;
      String? message = map['message'];
      showCustomSnackBarWidget(message, Get.context!, isError: false);
    }
    else {
      _isLoading = false;
      ApiChecker.checkApi( response);
    }
    notifyListeners();
  }


  Future<void> getInvoiceData(int? orderId) async {
    _isLoading = true;
    ApiResponse response = await cartServiceInterface.getInvoiceData(orderId);
    if(response.response != null && response.response!.statusCode == 200) {
      _discountOnProduct = 0;
      _totalTaxAmount = 0;
      _invoice = InvoiceModel.fromJson(response.response!.data);
      for(int i=0; i< _invoice!.details!.length; i++ ){
        _discountOnProduct += invoice!.details![i].discount!;
        // if(invoice!.details![i].productDetails!.taxModel == "exclude"){
        //   _totalTaxAmount += invoice!.details![i].tax!;
        // }
      }
      _isLoading = false;
    }else {
      _isLoading = false;
      ApiChecker.checkApi(response);
    }
    notifyListeners();
  }


  String? getBluetoothMacAddress() => cartServiceInterface.getBluetoothAddress();

  void setBluetoothMacAddress(String? address) => cartServiceInterface.setBluetoothAddress(address);


  void setPaidAmountles(bool value, {bool isUpdate = true}) {
    _isPaidAmountLess = value;
    if(isUpdate){
      notifyListeners();
    }
  }

  void setUpdatePaidAmount(bool value, {bool isUpdate = true}) {
    _isUpdatePaidAmount = value;
    if(isUpdate){
      notifyListeners();
    }
  }




  double calculateProductPrice(CartModel cartModel) {
    Product? product = cartModel.product;
    double? digitalVPrice = cartModel.digitalVariationPrice;
    Variation? variation = cartModel.variation;
    double? unitPrice = product?.unitPrice;
    double productDiscount = 0;

    if (product?.clearanceSale != null && product?.clearanceSale?.isActive == 1) {
      productDiscount = product!.clearanceSale?.discountType == 'flat'
        ? (product.clearanceSale?.discountAmount ?? 0) * cartModel.quantity!
        : ((product.clearanceSale?.discountAmount ?? 0) / 100) *
        (variation?.price ?? digitalVPrice ?? unitPrice!) *
        cartModel.quantity!;
    } else {
      productDiscount = product?.discountType == 'flat'
        ? product!.discount! * cartModel.quantity!
        : (product!.discount! / 100) *
        (variation?.price ?? digitalVPrice ?? unitPrice!) *
        cartModel.quantity!;
    }


    double productPrice = (variation?.price ?? digitalVPrice ?? unitPrice!) * cartModel.quantity!;
    return productPrice - productDiscount;
  }


  bool containsNumberExceptZero(String input) {
    final regex = RegExp(r'[1-9]');
    return regex.hasMatch(input);
  }


  double calculateInvoiceProductPrice(Details cartItem) {
    double productPrice = 0.0;
    double productDiscount = 0.0;
    double includeTax = 0.0;

    var productDetails = cartItem.productDetails;
    var variant = cartItem.variant;
    var qty = cartItem.qty;
    var discountType = productDetails?.discountType;
    var discount = productDetails?.discount;
    var taxModel = productDetails?.taxModel;



    // Check for variant and product type
    if (variant != null && variant.isNotEmpty && productDetails?.productType == 'physical') {

      Variation? variantMatch = productDetails?.variation?.where((v) => v.type == variant).isNotEmpty == true
          ? productDetails!.variation!.firstWhere((v) => v.type == variant) : null;

      if (variantMatch != null) {
        productPrice = variantMatch.price ?? 0;
      }

    } else if (variant != null && variant.isNotEmpty && productDetails?.productType == 'digital') {

      DigitalVariation? digitalVariation = productDetails?.digitalVariation?.where((v) => v.variantKey == variant).isNotEmpty == true
        ? productDetails!.digitalVariation!.firstWhere((v) => v.variantKey == variant) : null;

      if (digitalVariation != null) {
        productPrice = digitalVariation.price ?? 0;
      }
    } else {
      // If no variant or empty, use unit_price
      productPrice = productDetails?.unitPrice ?? 0;
    }

    // Calculate discount
    if (productDetails?.clearanceSale != null && productDetails?.clearanceSale?.isActive == 1) {
      if (productDetails?.clearanceSale?.discountType == 'flat') {
        productDiscount = (productDetails!.clearanceSale!.discountAmount! * qty!);
      } else {
        productDiscount = ((productDetails!.clearanceSale!.discountAmount! / 100) * productPrice * qty!);
      }
    } else {
      // Apply regular discount based on the type
      if (discountType == 'flat') {
        productDiscount = discount! * qty!;
      } else {
        productDiscount = (discount! / 100) * productPrice * qty!;
      }
    }

    // Apply tax if applicable
    //double priceAfterDiscount = (productPrice * qty) - productDiscount;
    double priceAfterDiscount = (productPrice * qty);

    if (taxModel == 'include') {
      includeTax = calculateIncludedTax(productPrice, productDetails!.tax!) * qty; // Tax is already included
    } else {
      // If tax is not included, apply tax
      // finalPrice = priceAfterDiscount + (productDetails['tax'] / 100) * priceAfterDiscount;
    }

    // Multiply by quantity and return final price
    //priceAfterDiscount *= qty;
    return priceAfterDiscount;
  }


  double calculateInvoiceProductDiscount(Details cartItem) {
    double productPrice = 0.0;
    double productDiscount = 0.0;
    double includeTax = 0.0;

    var productDetails = cartItem.productDetails;
    var variant = cartItem.variant;
    var qty = cartItem.qty;
    var discountType = productDetails?.discountType;
    var discount = productDetails?.discount;
    var taxModel = productDetails?.taxModel;



    // Check for variant and product type
    if (variant != null && variant.isNotEmpty && productDetails?.productType == 'physical') {

      Variation? variantMatch = productDetails?.variation?.where((v) => v.type == variant).isNotEmpty == true
          ? productDetails!.variation!.firstWhere((v) => v.type == variant) : null;

      if (variantMatch != null) {
        productPrice = variantMatch.price ?? 0;
      }

    } else if (variant != null && variant.isNotEmpty && productDetails?.productType == 'digital') {

      DigitalVariation? digitalVariation = productDetails?.digitalVariation?.where((v) => v.variantKey == variant).isNotEmpty == true
          ? productDetails!.digitalVariation!.firstWhere((v) => v.variantKey == variant) : null;

      if (digitalVariation != null) {
        productPrice = digitalVariation.price ?? 0;
      }
    } else {
      // If no variant or empty, use unit_price
      productPrice = productDetails?.unitPrice ?? 0;
    }

    // Calculate discount
    if (productDetails?.clearanceSale != null && productDetails?.clearanceSale?.isActive == 1) {
      if (productDetails?.clearanceSale?.discountType == 'flat') {
        productDiscount = (productDetails!.clearanceSale!.discountAmount! * qty!);
      } else {
        productDiscount = ((productDetails!.clearanceSale!.discountAmount! / 100) * productPrice * qty!);
      }
    } else {
      // Apply regular discount based on the type
      if (discountType == 'flat') {
        productDiscount = discount! * qty!;
      } else {
        productDiscount = (discount! / 100) * productPrice * qty!;
      }
    }

    // Apply tax if applicable
    //double priceAfterDiscount = (productPrice * qty) - productDiscount;

    if (taxModel == 'include') {
      includeTax = calculateIncludedTax(productPrice, productDetails!.tax!) * qty; // Tax is already included
    } else {
      // If tax is not included, apply tax
      // finalPrice = priceAfterDiscount + (productDetails['tax'] / 100) * priceAfterDiscount;
    }

    // Multiply by quantity and return final price
    //priceAfterDiscount *= qty;
    return productDiscount;
  }



  void initTempCartData({bool isUpdate = true}){
    _currentCartModel = getInitialTempCartData();
    if(isUpdate) {
      notifyListeners();
    }
  }

  TemporaryCartListModel getInitialTempCartData() {
    searchCustomerController.text = 'Walk-In Customer';

    Provider.of<CustomerController>(Get.context!, listen: false).setCustomerInfo(0, 'Walk-In Customer', null, false, 0);
    _customerBalance = 0;

    return TemporaryCartListModel(
      cart: [],
      userId: 0,
      customerName: 'Walk-In Customer',
      phoneNumber: '',
      customerBalance: 0,
    );
  }

  void emptyCustomerTextField() {
    _searchCustomerController.text = '';
  }


  Future<void> getTaxAmount() async {
    _isLoading = true;

    PlaceOrderBody? placeOrderBody =  onPlaceOrder();

    ApiResponse response = await cartServiceInterface.getTaxAmount(placeOrderBody);

    if(response.response != null && response.response!.statusCode == 200) {
      modifiedCart = PlaceOrderBody.fromJson(response.response?.data);
      if((modifiedCart?.totalTaxAmount ?? 0) > 0) {
        _isUpdatePaidAmount = true;
      }
      _isLoading = false;
    }else {
      _isLoading = false;
      ApiChecker.checkApi(response);
    }
    notifyListeners();
  }

  void removeModifiedTax({bool isUpdate = false}) {
    modifiedCart = null;
    _invoice = null;
    if(isUpdate) {
      notifyListeners();
    }
  }




}