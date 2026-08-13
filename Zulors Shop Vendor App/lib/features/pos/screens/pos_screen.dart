import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/coupon_discount_controller.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/customer_controller.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/place_order_body.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/cart_model.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/extra_discount_and_coupon_dialog_widget.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/pos_appbar_widget.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_dialog_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_divider_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/pos/screens/add_new_customer_screen.dart';
import 'package:zulors_shop_vendor/features/pos/screens/customer_search_screen.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/cart_pricing_widget.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/confirm_purchase_dialog_widget.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/coupon_apply_widget.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/item_card_widget.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/pos_no_product_widget.dart';
import '../../../main.dart';


class PosScreen extends StatefulWidget {
  final bool fromMenu;
  const PosScreen({super.key, this.fromMenu = false});

  @override
  State<PosScreen> createState() => PosScreenState();
}

class PosScreenState extends State<PosScreen> {

  final ScrollController _scrollController = ScrollController();
  double subTotal = 0;
  double productDiscount = 0;
  double total = 0;
  double payable = 0;
  double couponAmount = 0;
  double extraDiscountAmount = 0;
  double productTax = 0;
  double extraDiscount = 0;
  double payableWithoutExDiscount = 0;
  double includeTax = 0;
  bool hasDigitalProduct = false;

  int userId = 0;
  String customerName = '';
  final List<String> _paymentVia = ["cash", "card"];

  final TextEditingController _paidAmountController = TextEditingController();
  final FocusNode _paidAmountNode = FocusNode();
  bool isNotSet = true;


  @override
  void initState() {
    super.initState();


    final cartController = Provider.of<CartController>(context, listen: false);
    final customerController = Provider.of<CustomerController>(context, listen: false);

    if(cartController.currentCartModel == null) {
      cartController.initTempCartData(isUpdate: false);
    }

    if(Provider.of<CouponDiscountController>(context, listen: false).selectedDiscountType == null ||  Provider.of<CouponDiscountController>(context, listen: false).selectedDiscountType!.isEmpty) {
      Provider.of<CouponDiscountController>(context, listen: false).setSelectedDiscountType('amount');
      Provider.of<CouponDiscountController>(context, listen: false).setDiscountTypeIndex(0, false);
    }

    if(Provider.of<SplashController>(context, listen: false).configModel?.walletStatus ?? false) {
      _paymentVia.add("wallet");
    }

    customerController.getCustomerList('all');

    cartController.clearCardForCancel();
    cartController.extraDiscountController.text = '0';
    cartController.setPaidAmountles(true, isUpdate: false);
    cartController.setUpdatePaidAmount(true, isUpdate: false);
    if(customerController.customerSelectedName == '') {
      cartController.searchCustomerController.text = 'Walk-In Customer';
      customerController.setCustomerInfo(0,  'Walk-In Customer', '', false, 0,  fromInit: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const PosAppbarWidget(),
      body: RefreshIndicator(
        color: Theme.of(context).cardColor,
        backgroundColor: Theme.of(context).primaryColor,
        onRefresh: () async {
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: Consumer<CartController>(
              builder: (context,cartController, _) {
                  hasDigitalProduct = false;
                  productDiscount = 0;
                  total = 0;
                  productTax = 0;
                  subTotal = 0;
                  includeTax = 0;

                  List<CartModel> cartList = [];


                  if( cartController.currentCartModel != null && ((cartController.currentCartModel?.cart?.length ?? 0) > 0) ) {
                    subTotal = cartController.amount;
                    cartList = cartController.currentCartModel?.cart ?? [];

                    _calculateCartDetails(cartController, cartList);
                  }


                  if(cartController.currentCartModel != null) {
                    couponAmount = cartController.currentCartModel?.couponAmount ?? 0;
                    extraDiscount = cartController.currentCartModel?.extraDiscount ?? 0;
                  }

                  payableWithoutExDiscount = subTotal - productDiscount - couponAmount;

                  extraDiscountAmount =
                    Provider.of<CouponDiscountController>(context, listen: false).selectedDiscountType == 'percent' ?
                    double.parse(PriceConverter.discountCalculationWithOutSymbol(context, payableWithoutExDiscount, extraDiscount, Provider.of<CouponDiscountController>(context, listen: false).selectedDiscountType, convertCurrency: true)) :
                    double.parse(PriceConverter.discountCalculationWithOutSymbol(context, payableWithoutExDiscount, extraDiscount, Provider.of<CouponDiscountController>(context, listen: false).selectedDiscountType, convertCurrency: false));

                  total = subTotal - productDiscount - couponAmount - double.tryParse(PriceConverter.reverseConvertPriceWithoutSymbol(context, extraDiscountAmount))! + productTax;

                  payable = total;

                  // debugPrint("<<====InitCall=====>>${cartController.currentCartModel?.toJson()}");
                  // print('----01---${PriceConverter.convertPrice(context, subTotal)}');
                  // print('----02---${PriceConverter.convertPrice(context, couponAmount)}');
                  // print('----03---${PriceConverter.convertPrice(context, (subTotal - couponAmount))}');
                  //
                  // print('----TYPE---${Provider.of<CouponDiscountController>(context, listen: false).selectedDiscountType}');


                  if(isNotSet || cartController.updatePaidAmount) {
                    _paidAmountController.text = PriceConverter.convertPriceWithoutSymbol(context, payable);
                    cartController.setPaidAmountles(false, isUpdate: false);
                    if(cartController.updatePaidAmount) {
                      cartController.setUpdatePaidAmount(false, isUpdate: false);
                    }
                    isNotSet = false;
                  }


                  return SingleChildScrollView(
                    child: Column(children: [
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Consumer<CustomerController>(
                        builder: (context,customerController,_) {
                          return Container(
                              padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, 0),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start ,children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const CustomerSearchScreen())),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(width: .50, color: Theme.of(context).primaryColor.withValues(alpha:.75)),
                                                  color: Theme.of(context).cardColor,
                                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
                                              ),
                                              child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSize),
                                                  child: Text(cartController.searchCustomerController.text, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color) ))
                                          )
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),


                                    InkWell(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddNewCustomerScreen()));
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                                        ),
                                        child: Icon(Icons.person_add_alt_1_sharp, color: Theme.of(context).cardColor),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: Dimensions.paddingSizeDefault),

                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 20),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),

                                    Text('${getTranslated('customer_information', context)} :',
                                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                Text(
                                    '${getTranslated('name', context)}     : ${customerController.customerSelectedName ?? ''}', maxLines: 1,overflow: TextOverflow.ellipsis,
                                    style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)
                                ),

                                if(customerController.customerSelectedMobile != 'NULL' && customerController.customerSelectedMobile != '' && cartController.containsNumberExceptZero(customerController.customerSelectedMobile ?? ''))...[
                                  Text( '${getTranslated('phone_no', context)} : ${customerController.customerSelectedMobile != 'NULL'? customerController.customerSelectedMobile??'':''}',
                                    style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)
                                  ),
                                ],
                              ]),
                          );
                        }
                      ),

                      const SizedBox(height: 35),

                      Container(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, 0),
                        height: 50,
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha:.06),),
                        child: Row(children: [

                          Expanded(flex:4, child: Text(getTranslated('item_info', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))),
                          Expanded(flex:4, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(getTranslated('qty', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))
                          ])),
                          Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                              Text(getTranslated('price', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))
                            ],
                          )),
                        ]),
                      ),
                      (cartController.currentCartModel?.cart?.length  ?? 0) > 0 ?
                      Consumer<CartController>(builder: (context,custController,_) {
                        return ListView.builder(
                          itemCount: cartController.currentCartModel?.cart?.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (itemContext, index){
                            return ItemCartWidget(cartModel: cartController.currentCartModel?.cart![index], index:  index, onChanged: () {
                              isNotSet=true;
                            },);
                          });
                      }) : const SizedBox(),
                    
                    
                      (cartController.currentCartModel != null && (cartController.currentCartModel?.cart?.length  ?? 0) > 0) ?
                      Padding(
                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeMedium),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow: [BoxShadow(color: Provider.of<ThemeController>(context, listen: false).darkTheme? Theme.of(context).primaryColor.withValues(alpha:0):
                            Theme.of(context).primaryColor.withValues(alpha:.05), blurRadius: 1, spreadRadius: 1, offset: const Offset(0,0))]
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                    
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(Dimensions.fontSizeDefault,  Dimensions.paddingSizeExtraSmall, Dimensions.fontSizeDefault,Dimensions.fontSizeDefault,),
                              child: Row(children: [
                                Expanded(child: Text(getTranslated('bill_summery', context)!,
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color))),
                                SizedBox(width: 120,height: 40,child: CustomButtonWidget(btnTxt: getTranslated('edit_discount', context),
                                  onTap: () async {
                                    await showDialog<bool>(
                                      context: context, builder: (ctx) => Stack(
                                        children: [
                                          Positioned(
                                            top: 50, left: 0, right: 0,
                                            child: Material(
                                              type: MaterialType.transparency, // Make sure the dialog has material styling
                                              child: ExtraDiscountAndCouponDialogWidget(
                                                payable: payableWithoutExDiscount,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    );
                                  },)),
                              ],),
                            ),
                            PricingWidget(title: getTranslated('subtotal', context), amount: PriceConverter.convertPrice(context, subTotal+includeTax)),
                            PricingWidget(title: getTranslated('product_discount', context), amount: PriceConverter.convertPrice(context,productDiscount)),
                            PricingWidget(title: getTranslated('coupon_discount', context), amount: PriceConverter.convertPrice(context,couponAmount),
                              isCoupon: true, onTap: () {
                                showAnimatedDialogWidget(
                                  context,
                                  CouponDialogWidget(extraDiscountAmount: extraDiscountAmount, productDiscountAmount: productDiscount),
                                  dismissible: false,
                                  isFlip: false
                                );
                              }
                            ),
                            PricingWidget(title: getTranslated('extra_discount', context), amount: PriceConverter.discountCalculation(context,
                                subTotal, extraDiscountAmount, 'amount')),
                            PricingWidget(title: getTranslated('vat', context), amount: PriceConverter.convertPrice(context, cartController.modifiedCart?.totalTaxAmount ?? 0)),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                              child: CustomDividerWidget(height: .4,color: Theme.of(context).hintColor.withValues(alpha:1),),),
                    
                            PricingWidget(title: getTranslated('total', context), amount: PriceConverter.convertPrice(context, total), isTotal: true),



                            Padding( padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall,
                              Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall),
                              child: Text(getTranslated('paid_by', context)!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color))
                            ),

                            Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                              child: Consumer<CustomerController>(
                                  builder: (context, customerProvider, _) {
                                  return SizedBox(height: 35, child: ListView.builder(
                                      itemCount:(customerProvider.customerId != 0 && !customerProvider.customerSelectedName!.contains('Walk')) ? _paymentVia.length : 2,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index){
                                        return Padding(
                                          padding:  const EdgeInsets.only(left : Dimensions.paddingSizeSmall),
                                          child: GestureDetector(
                                            onTap: () {
                                              cartController.setPaymentTypeIndex(index, true);
                                              _paidAmountController.text = PriceConverter.convertPriceWithoutSymbol(context, payable);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                              decoration: BoxDecoration(
                                                  color: cartController.paymentTypeIndex == index? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                                  border: Border.all(width: .5, color: Theme.of(context).hintColor)
                                              ),
                                              child: Center(child: Text(getTranslated(_paymentVia[index], context)!,
                                                style: robotoRegular.copyWith(color: cartController.paymentTypeIndex == index?
                                                Colors.white :  Theme.of(context).textTheme.bodyLarge?.color, fontSize: cartController.paymentTypeIndex == index? Dimensions.fontSizeLarge : Dimensions.fontSizeDefault),)),
                                            ),
                                          ),
                                        );
                                      }));
                                }
                              ),
                            ),

                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                              child: Container (
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSeven, vertical: Dimensions.paddingSize),
                                decoration: BoxDecoration (
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  color: Theme.of(context).hintColor.withValues(alpha:0.10),
                                  border: Border.all(color: Theme.of(context).hintColor.withValues(alpha:0.30))
                                ),
                                child: Consumer<CustomerController>(
                                  builder: (context, customerController, _) {
                                    return Column( crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        (cartController.paymentTypeIndex ==2 && !customerController.checkWalletAmount(
                                            customerController.customerId, payable)) ?
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                              child: Container(
                                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                                decoration: BoxDecoration (
                                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                  color: Theme.of(context).colorScheme.error.withValues(alpha:0.30),
                                                ),
                                                child: Text(
                                                  getTranslated('insufficient_balance', context)!,
                                                  style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error),
                                                ),
                                              ),
                                            ),
                                          ) : const SizedBox(),

                                        (cartController.paymentTypeIndex ==2 && !customerController.checkWalletAmount(customerController.customerId, payable)) ?
                                           const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),


                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [

                                              Text('${getTranslated('paid_amount', context)!} :', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),

                                              SizedBox(
                                                height: 45, width: 150,
                                                child: CustomTextFieldWidget(
                                                  idDate: cartController.paymentTypeIndex != 0,
                                                  border: true,
                                                  hintText: getTranslated('amount', context),
                                                  controller: _paidAmountController,
                                                  focusNode: _paidAmountNode,
                                                  textInputAction: TextInputAction.next,
                                                  textInputType: TextInputType.number,
                                                  borderColor: cartController.isPaidAmountLess ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                                                  //showBorder: true,
                                                  isAmount: true,
                                                  focusBorder: true,
                                                  onChanged: (value) {
                                                    double? amount = double.tryParse(value);
                                                    if(amount != null && (amount >= total)) {
                                                      cartController.setPaidAmountles(false);
                                                    } else if (amount != null && (amount < total) && !cartController.isPaidAmountLess) {
                                                      cartController.setPaidAmountles(true);
                                                    }

                                                    if (_paidAmountNode.hasFocus && MediaQuery.of(context).viewInsets.bottom > 0) {
                                                      // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                                                      // FocusScope.of(context).unfocus();
                                                    }
                                                  },
                                                  // isAmount: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: Dimensions.paddingSizeSmall),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('${getTranslated('change_amount', context)!} :', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),

                                              Text(getChangeAmount(context),
                                                style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)
                                              ),
                                            ],
                                          ),
                                        ),
                                         const SizedBox(height: Dimensions.paddingSizeDefault),
                                      ],
                                    );
                                  }
                                ),
                              ),
                            ),
                            SizedBox(height:  MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : Dimensions.paddingSizeDefault),
                    
                    
                    
                    
                            Container(
                              padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0,
                              Dimensions.paddingSizeDefault, Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                boxShadow: [
                                  BoxShadow(color: Provider.of<ThemeController>(context, listen: false).darkTheme? Theme.of(context).primaryColor.withValues(alpha:0):
                                  Theme.of(context).primaryColor.withValues(alpha:.10),
                                    offset: const Offset(0, 2.0), blurRadius: 4.0,
                                  )
                                ]
                              ),

                              height: 50,child: Row(children: [
                                Expanded(
                                  flex: 3,
                                  child: InkWell(
                                    onTap: cartController.isLoading ? null : () {
                                      subTotal = 0; productDiscount = 0; total = 0; payable = 0; couponAmount = 0; extraDiscountAmount = 0; productTax = 0;
                                      cartController.resetUserCard();
                                      // cartController.saveCardData();
                                    },
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color:  cartController.isLoading ? Theme.of(context).hintColor.withValues(alpha:0.25) : Theme.of(context).colorScheme.error.withValues(alpha:0.25),
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                          border: Border.all(color:  cartController.isLoading ? Theme.of(context).hintColor.withValues(alpha:0.25) : Theme.of(context).colorScheme.error.withValues(alpha:0.50) )
                                      ),
                                      child: Center(
                                        child: Text(
                                          getTranslated('clear', context)!,
                                          style: robotoMedium.copyWith(color: cartController.isLoading ? Theme.of(context).hintColor : Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),


                                Expanded(
                                  flex: 3,
                                  child: InkWell(
                                    onTap: cartController.isLoading ? null : () {
                                      if((cartController.currentCartModel?.cart?.length ?? 0) <= 0) {
                                        showCustomSnackBarWidget(getTranslated('no_item_in_your_cart', context)!, context);
                                      } else {
                                        cartController.addToHoldUserList();
                                        cartController.removeModifiedTax();
                                      }
                                    },
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: cartController.isLoading ? Theme.of(context).hintColor.withValues(alpha:0.25) : Theme.of(context).colorScheme.onSecondary.withValues(alpha:0.25),
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        border: Border.all(color: cartController.isLoading ? Theme.of(context).hintColor.withValues(alpha:0.50) : Theme.of(context).colorScheme.error.withValues(alpha:0.50) )
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.pause, color: cartController.isLoading ? Theme.of(context).hintColor : Theme.of(context).colorScheme.onSecondary),
                                            const SizedBox(width: Dimensions.paddingSizeSmall),

                                            Text(
                                              getTranslated('hold', context)!,
                                              style: robotoMedium.copyWith(color: cartController.isLoading ? Theme.of(context).hintColor : Theme.of(context).colorScheme.onSecondary, fontSize: Dimensions.fontSizeSmall),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),


                                Expanded(flex: 5,
                                  child: cartController.isLoading ?
                                   const Center(child: SizedBox(height: 25,  width: 25, child: CircularProgressIndicator(strokeWidth: 2))) :
                                  Consumer<CouponDiscountController>(
                                      builder: (context, couponDiscountController,_) {
                                        return CustomButtonWidget(btnTxt: getTranslated('place_order', context),
                                        onTap: () {
                                          debugPrint("===123456===>>${cartController.customerCartList.length}");

                                          CustomerController customerController = Provider.of<CustomerController>(context, listen: false);

                                          if(hasDigitalProduct && (customerController.customerId.toString().length == 4 || customerController.customerId == 0)) {
                                            showCustomSnackBarWidget(getTranslated('orders_with_digital_products', context), context, sanckBarType: SnackBarType.warning);
                                          } else if((cartController.paymentTypeIndex == 0 && cartController.isPaidAmountLess)) {
                                            showCustomSnackBarWidget(getTranslated('paid_amount_cannot_less_then_order_amount', context), context, sanckBarType: SnackBarType.warning);
                                          } else if(double.tryParse(_paidAmountController.text) ==0){
                                            showCustomSnackBarWidget(getTranslated('paid_amount_cannot_zero', context), context, sanckBarType: SnackBarType.warning);
                                          } else if (cartController.paymentTypeIndex ==2 && !customerController.checkWalletAmount(customerController.customerId, payable)) {
                                            showCustomSnackBarWidget(getTranslated('your_wallet_balance_is_less_then_order_amount', context), context, sanckBarType: SnackBarType.warning);
                                          } else if((cartController.currentCartModel?.cart?.length ?? 0) <= 0)  {
                                            showCustomSnackBarWidget(getTranslated('please_select_at_least_one_product', context), context);
                                          }
                                          else{
                                            showAnimatedDialogWidget(context,
                                              ConfirmPurchaseDialogWidget(
                                                onYesPressed: cartController.isLoading ? null : () {
                                                  List<Cart> carts = [];
                                                  productDiscount = 0;
                                                  for (int index = 0; index < (cartController.currentCartModel?.cart?.length ?? 0); index++) {
                                                    CartModel cart = cartController.currentCartModel!.cart![index];
                                                    double? digitalVPrice = cart.digitalVariationPrice;
                                                    carts.add(Cart(
                                                      cart.product!.id.toString(),
                                                      cart.price.toString(),
                                                      cart.product!.discountType == 'flat'?
                                                      productDiscount + cart.product!.discount! : productDiscount + ((cart.product!.discount!/100)* (digitalVPrice ?? cart.product!.unitPrice!)),
                                                      cart.quantity,
                                                      cart.variant,
                                                      cart.varientKey,
                                                      cart.digitalVariationPrice,
                                                      cart.variation !=null ?
                                                      [cart.variation] : [],
                                                    ));
                                                  }


                                                  PlaceOrderBody placeOrderBody = onPlaceOrder(paidAmount: _paidAmountController.text);

                                                  cartController.placeOrder(Get.context!, placeOrderBody).then((value) {
                                                    if(value.response!.statusCode == 200) {
                                                      couponAmount = 0;
                                                      extraDiscountAmount = 0;
                                                      cartController.removeModifiedTax();
                                                    }
                                                  });

                                                }
                                              ),
                                             dismissible: false, isFlip: false
                                            );
                                          }
                                        });
                                      }
                                    )
                                ),
                            ],),),
                    
                    
                            const SizedBox(height: Dimensions.paddingSizeRevenueBottom),

                          ],),),
                      ) : const PosNoProductWidget(),
                    ],),
                  );

                }
            ))
          ],
        ),
      ),
    );
  }



  // PlaceOrderBody placeOrder() {
  //   CartController cartController = Provider.of<CartController>(context,listen: false);
  //   CustomerController customerController = Provider.of<CustomerController>(context,listen: false);
  //   CouponDiscountController couponDiscountController = Provider.of<CouponDiscountController>(context,listen: false);
  //
  //   List<Cart> carts = [];
  //   productDiscount = 0;
  //   for (int index = 0; index < (cartController.currentCartModel?.cart?.length ?? 0); index++) {
  //     CartModel cart = cartController.currentCartModel!.cart![index];
  //     double? digitalVPrice = cart.digitalVariationPrice;
  //     carts.add(Cart(
  //       cart.product!.id.toString(),
  //       cart.price.toString(),
  //       cart.product!.discountType == 'flat'?
  //       productDiscount + cart.product!.discount! : productDiscount + ((cart.product!.discount!/100)* (digitalVPrice ?? cart.product!.unitPrice!)),
  //       cart.quantity,
  //       cart.variant,
  //       cart.varientKey,
  //       cart.digitalVariationPrice,
  //       cart.variation !=null ?
  //       [cart.variation] : [],
  //     ));
  //   }
  //
  //   PlaceOrderBody placeOrderBody = PlaceOrderBody(
  //     cart: carts,
  //     couponDiscountAmount: cartController.couponCodeAmount,
  //     couponCode: cartController.currentCartModel?.couponCode,
  //     couponAmount: cartController.currentCartModel?.couponAmount,
  //     orderAmount: double.tryParse(PriceConverter.convertPriceWithoutSymbol(context, cartController.amount)),
  //     userId:  customerController.customerId.toString().length == 4 ? 0 : customerController.customerId,
  //     extraDiscountType: couponDiscountController.selectedDiscountType,
  //     paymentMethod: cartController.paymentTypeIndex == 0 ? 'cash' : cartController.paymentTypeIndex == 1 ? 'card' : 'wallet' ,
  //     extraDiscount: couponDiscountController.extraDiscountController.text.trim().isEmpty ? 0.0 :
  //     couponDiscountController.selectedDiscountType == 'percent' ? cartController.currentCartModel?.extraDiscount :
  //     extraDiscountAmount,
  //     paidAmount: double.tryParse(_paidAmountController.text)
  //   );
  //
  //   return placeOrderBody;
  // }


  String getChangeAmount(BuildContext context) {
    final paidAmountText = _paidAmountController.text;

    final reversedPaidAmountStr = PriceConverter.reverseConvertPriceWithoutSymbol(
      context,
      double.tryParse(paidAmountText),
      removeDecimalPoint: false,
    );

    final reversedPaidAmount = double.tryParse(reversedPaidAmountStr) ?? 0.0;
    final totalAmount = double.tryParse(total.toString()) ?? 0.0;

    return _sanitizeNegativeZero(PriceConverter.convertPrice(context, reversedPaidAmount - totalAmount));
  }


  void _calculateCartDetails(CartController cartController, List<CartModel> cartList) {
    for (var cartItem in cartList) {
      double productUnitPrice = _getProductUnitPrice(cartItem);
      int productQuantity = cartItem.quantity ?? 0;

      /// Product Discount
      if (cartItem.product?.clearanceSale != null && cartItem.product?.clearanceSale?.isActive == 1) {
        productDiscount += _calculateClearanceDiscount(cartItem, productUnitPrice, productQuantity);
      } else {
        productDiscount += _calculateDiscount(cartItem, productUnitPrice, productQuantity);
      }

      /// Tax Calculation
      // if (cartItem.product?.taxModel == "exclude") {
      //   productTax += ((cartItem.product?.tax ?? 0) / 100) * productUnitPrice * productQuantity;
      // } else if (cartItem.product?.taxModel == "include") {
      //   double _includeTax = cartController.calculateIncludedTax(
      //     (productUnitPrice * productQuantity),
      //     (cartItem.product?.tax ?? 0),
      //   );
      //   productTax += _includeTax;
      //   includeTax += _includeTax;
      // }
      productTax = cartController.modifiedCart?.totalTaxAmount ?? 0;

      /// Check for Digital Product
      if (cartItem.product?.productType == 'digital' && !hasDigitalProduct) {
        hasDigitalProduct = true;
      }
    }
  }


  double _calculateClearanceDiscount(CartModel cartItem, double unitPrice, int quantity) {
    if (cartItem.product?.clearanceSale != null && cartItem.product?.clearanceSale?.isActive == 1) {
      double discountAmount = cartItem.product?.clearanceSale?.discountAmount ?? 0;

      return (cartItem.product!.clearanceSale?.discountType == 'flat')
        ? discountAmount * quantity
        : (discountAmount / 100) * unitPrice * quantity;
    }
    return 0;
  }


  double _calculateDiscount(CartModel cartItem, double unitPrice, int quantity) {
    double discountAmount = cartItem.product?.discount ?? 0;

    if (cartItem.product!.discountType == 'flat') {
      return discountAmount * quantity;
    } else {
      return (discountAmount / 100) * unitPrice * quantity;
    }
  }


  double _getProductUnitPrice (CartModel cartModel) {
    double unitPrice = 0;

    if(cartModel.variation != null) {
      unitPrice = cartModel.variation!.price!;
    } else if (cartModel.digitalVariationPrice != null) {
      unitPrice = cartModel.digitalVariationPrice!;
    } else {
      unitPrice = cartModel.price ?? 0;
    }
    return unitPrice;
  }


  String _sanitizeNegativeZero(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9\.-]'), '');

    final numValue = double.tryParse(cleaned) ?? 0.0;

    if (numValue == 0.0) {
      return value.replaceFirst('-', '');
    }
    return value;
  }
}

PlaceOrderBody onPlaceOrder({String? paidAmount}) {
  CartController cartController = Provider.of<CartController>(Get.context!,listen: false);
  CustomerController customerController = Provider.of<CustomerController>(Get.context!,listen: false);
  CouponDiscountController couponDiscountController = Provider.of<CouponDiscountController>(Get.context!,listen: false);

  List<Cart> carts = [];
  double productDiscount = 0;

  double extraDiscount = cartController.currentCartModel?.extraDiscount ?? 0;
  double subTotal = cartController.amount;

  double extraDiscountAmount =
  Provider.of<CouponDiscountController>(Get.context!, listen: false).selectedDiscountType == 'percent' ?
  double.parse(PriceConverter.discountCalculationWithOutSymbol(Get.context!, subTotal, extraDiscount, Provider.of<CouponDiscountController>(Get.context!, listen: false).selectedDiscountType, convertCurrency: true)) :
  double.parse(PriceConverter.discountCalculationWithOutSymbol(Get.context!, subTotal, extraDiscount, Provider.of<CouponDiscountController>(Get.context!, listen: false).selectedDiscountType, convertCurrency: false));


  for (int index = 0; index < (cartController.currentCartModel?.cart?.length ?? 0); index++) {
    CartModel cart = cartController.currentCartModel!.cart![index];
    double? digitalVPrice = cart.digitalVariationPrice;
    carts.add(Cart(
      cart.product!.id.toString(),
      cart.price.toString(),
      cart.product!.discountType == 'flat'?
      productDiscount + cart.product!.discount! : productDiscount + ((cart.product!.discount!/100)* (digitalVPrice ?? cart.product!.unitPrice!)),
      cart.quantity,
      cart.variant,
      cart.varientKey,
      cart.digitalVariationPrice,
      cart.variation !=null ?
      [cart.variation] : [],
    ));
  }



  PlaceOrderBody placeOrderBody = PlaceOrderBody(
    cart: carts,
    couponDiscountAmount: cartController.couponCodeAmount,
    couponCode: cartController.currentCartModel?.couponCode,
    couponAmount: cartController.currentCartModel?.couponAmount,
    orderAmount: double.tryParse(PriceConverter.convertPriceWithoutSymbol(Get.context!, cartController.amount)),
    userId:  customerController.customerId.toString().length == 4 ? 0 : customerController.customerId,
    extraDiscountType: couponDiscountController.selectedDiscountType,
    paymentMethod: cartController.paymentTypeIndex == 0 ? 'cash' : cartController.paymentTypeIndex == 1 ? 'card' : 'wallet' ,
    extraDiscount: couponDiscountController.extraDiscountController.text.trim().isEmpty ? 0.0 :
    couponDiscountController.selectedDiscountType == 'percent' ? cartController.currentCartModel?.extraDiscount :
    extraDiscountAmount,
    totalTaxAmount: cartController.modifiedCart?.totalTaxAmount ?? 0,
    paidAmount: paidAmount != null ? double.tryParse(paidAmount) : null,
    modifiedCart: cartController.modifiedCart?.modifiedCart,
  );

  return placeOrderBody;
}



double getPayableWithExtraDiscount() {
  CartController cartController = Provider.of<CartController>(Get.context!,listen: false);
  double productDiscount = 0;


  for (int index = 0; index < (cartController.currentCartModel?.cart?.length ?? 0); index++) {
    CartModel cartItem = cartController.currentCartModel!.cart![index];
    double productUnitPrice = _getProductUnitPrice(cartItem);

    if (cartItem.product?.clearanceSale != null && cartItem.product?.clearanceSale?.isActive == 1) {
      productDiscount += _calculateClearanceDiscount(cartItem, productUnitPrice, cartItem.quantity ?? 0);
    } else {
      productDiscount += _calculateDiscount(cartItem, productUnitPrice, cartItem.quantity ?? 0);
    }

  }

  return (cartController.amount - productDiscount);
}


double _calculateClearanceDiscount(CartModel cartItem, double unitPrice, int quantity) {
  if (cartItem.product?.clearanceSale != null && cartItem.product?.clearanceSale?.isActive == 1) {
    double discountAmount = cartItem.product?.clearanceSale?.discountAmount ?? 0;

    return (cartItem.product!.clearanceSale?.discountType == 'flat')
        ? discountAmount * quantity
        : (discountAmount / 100) * unitPrice * quantity;
  }
  return 0;
}


double _calculateDiscount(CartModel cartItem, double unitPrice, int quantity) {
  double discountAmount = cartItem.product?.discount ?? 0;

  if (cartItem.product!.discountType == 'flat') {
    return discountAmount * quantity;
  } else {
    return (discountAmount / 100) * unitPrice * quantity;
  }
}

double _getProductUnitPrice (CartModel cartModel) {
  double unitPrice = 0;

  if(cartModel.variation != null) {
    unitPrice = cartModel.variation!.price!;
  } else if (cartModel.digitalVariationPrice != null) {
    unitPrice = cartModel.digitalVariationPrice!;
  } else {
    unitPrice = cartModel.price ?? 0;
  }
  return unitPrice;
}

