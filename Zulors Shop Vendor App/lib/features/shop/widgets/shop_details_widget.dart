import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/guideline_warning_widget.dart';
import 'package:zulors_shop_vendor/features/addProduct/screens/add_product_screen.dart';
import 'package:zulors_shop_vendor/features/shop/controllers/shop_controller.dart';
import 'package:zulors_shop_vendor/features/shop/screens/vacation_mode_setup_screen.dart';
import 'package:zulors_shop_vendor/features/shop/widgets/shop_card_widget.dart';
import 'package:zulors_shop_vendor/features/shop/widgets/status_change_botomsheet_widget.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';


class ShopDetailsWidget extends StatefulWidget {
  const ShopDetailsWidget({super.key});

  @override
  State<ShopDetailsWidget> createState() => _ShopDetailsWidgetState();
}

class _ShopDetailsWidgetState extends State<ShopDetailsWidget> {
  String sellerId = '0';

  TextEditingController vacationNote = TextEditingController();

  bool freeDeliveryOver = false;

  TextEditingController minimumOrderAmountController = TextEditingController();

  TextEditingController freeDeliveryOverAmountController = TextEditingController();

  bool freeDeliveryOn = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopController>(
      builder: (context, shopInfo, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
          child: SingleChildScrollView(
            child: Column(
              children: [

                if(shopInfo.showAddProductWarning && shopInfo.shopModel?.totalProducts != null && ((shopInfo.shopModel?.totalProducts ?? 0) < 1))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: GuidelineWarningWidget(
                    guidelineStatus: GuidelineStatus.warning,
                    content: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color),
                        children: <InlineSpan>[
                          TextSpan(text: getTranslated('manage_your_shop_decoration', context) ?? ''),
                          const WidgetSpan(child: SizedBox(width: Dimensions.paddingSizeSmall)),
            
                          WidgetSpan(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_)=> const AddProductScreen()));
                              },
                              child: Text(
                                getTranslated('add_new_product', context) ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  color: Theme.of(context).primaryColor,
                                  decorationColor: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          ),
                        ],
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    showCrossButton: true,
                    onPressed: () => shopInfo.setShowAddProductWarning(false),
                  ),
                ),
            
                const ShopCardWidget(),


                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: GuidelineWarningWidget(
                    guidelineStatus: ((shopInfo.shopModel?.temporaryClose ?? false) && !(shopInfo.shopModel?.vacationStatus ?? false))
                     ? GuidelineStatus.success :
                     (shopInfo.shopModel?.vacationStatus ?? false) ?
                     GuidelineStatus.error :
                     GuidelineStatus.warning,

                    content: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color),
                        children: <InlineSpan>[
                          if(!(shopInfo.shopModel!.temporaryClose ?? false))...[
                            TextSpan(text: getTranslated('your_shop_is_currently', context) ?? ''),
                            TextSpan(
                              text: getTranslated('shop_availability_status', context) ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: getTranslated('is_turned_off', context) ?? ''),
                          ],

                          if((shopInfo.shopModel?.temporaryClose ?? false) && !(shopInfo.shopModel?.vacationStatus ?? false))...[
                            TextSpan(
                              text: getTranslated('your_shop_is_running_up_do_date', context) ?? '',
                              style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.onTertiaryContainer),
                            ),
                          ],

                          if((shopInfo.shopModel?.vacationStatus ?? false) && (shopInfo.shopModel?.temporaryClose ?? false))...[
                            TextSpan(
                              text: getTranslated('you_have_scheduled_shop', context) ?? '',
                              style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error),
                            ),

                            TextSpan(
                              text: DateConverter.localToIsoString(DateTime.tryParse(shopInfo.shopModel?.vacationStartDate ?? '') ?? DateTime.now()),
                              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error),
                            ),

                            TextSpan(
                              text: getTranslated('to', context) ?? '',
                              style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error),
                            ),

                            TextSpan(
                              text: DateConverter.localToIsoString(DateTime.tryParse(shopInfo.shopModel?.vacationStartDate ?? '') ?? DateTime.now()),
                              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error),
                            ),

                            TextSpan(
                              text: getTranslated('if_you_wish_to_reopen_your_shop', context) ?? '',
                              style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error),
                            ),
                          ]
                        ],
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    showCrossButton: false,
                  ),
                ),

            
                Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                    boxShadow: ThemeShadow.getShadow(context)
                  ), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(getTranslated('setup_store_mode', context) ?? '',
                      style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeLarge)
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).hintColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                        // boxShadow: ThemeShadow.getShadow(context)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(getTranslated('store_availability', context) ?? '',
                            style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeLarge)
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Text(getTranslated('turning_off_the_status_will', context) ?? '',
                            style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeDefault)
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          shopInfo.shopModel != null?
                          ShopSettingWidget(
                            title: 'statuss', mode: shopInfo.shopModel?.temporaryClose != null ?
                          shopInfo.shopModel!.temporaryClose : false,
                            onTap: (value){
                              showModalBottomSheet(context: context, isScrollControlled: true,
                                backgroundColor: Theme.of(context).primaryColor.withValues(alpha:0),
                                builder: (con) => StatusChangeBottomSheetWidget(
                                  title: !(shopInfo.shopModel?.temporaryClose ?? false) ?
                                  ((getTranslated('do_you_want_to_make_your_store_unavailable', context) ?? ''))
                                  : (getTranslated('do_you_want_to_make_your_store', context) ?? ''),
                                  subtitle: !(shopInfo.shopModel?.temporaryClose ?? false) ?
                                  getTranslated('turning_on_the_status_will_deactivate', context) :
                                  getTranslated('turning_on_the_status_will_activate', context) ,
                                  onNoPressed: () {},
                                  onYesPressed: () {
                                    shopInfo.shopTemporaryClose(context, shopInfo.shopModel!.temporaryClose! ? 1 : 0);
                                  } ,
                                )
                              );
                            },
                          ): const SizedBox(),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),


                    Opacity(
                      opacity: !(shopInfo.shopModel?.temporaryClose ?? false) ?  0.4 : 1.0,
                      child: IgnorePointer(
                        ignoring: !(shopInfo.shopModel?.temporaryClose ?? false),
                        child: Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).hintColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(getTranslated('go_vacation_mode', context) ?? '',
                                    style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeLarge)
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),

                                  if(shopInfo.shopModel?.vacationStatus ?? false)
                                  Text(getTranslated('active', context) ?? '',
                                    style: robotoBold.copyWith(color: Theme.of(context).colorScheme.onTertiaryContainer, fontSize: Dimensions.fontSizeSmall)
                                  ),
                                ],
                              ),



                              Text(getTranslated('if_you_turn_on_your_shop', context) ?? '',
                                style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeDefault)
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              CustomButtonWidget(
                                borderRadius: Dimensions.radiusDefault,
                                btnTxt: getTranslated('setup_vacation_mode', context),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VacationModeScreen()));
                                }
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),


                  ],
                  ),
                  ),
                ),
            

            
            
            
            
            
            
            
            
              ],
            ),
          ),
        );
      }
    );
  }
}





class ShopSettingWidget extends StatelessWidget {
  final String? title;
  final String? icon;
  final bool? mode;
  final Function(bool value)? onTap;
  final Function()? onPress;
  final bool dateSelection;
  final bool showBorder;
  final Color? borderColor;
  const ShopSettingWidget({super.key, this.title, this.icon, this.mode, this.onTap, this.dateSelection = false, this.onPress, this.showBorder = true, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopController>(
        builder: (context, shop,_) {
          return Container(
            padding: showBorder ? const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSize) : null,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: showBorder ? Border.all(color: borderColor ?? Theme.of(context).hintColor.withValues(alpha: 0.50), width: 1.5) : null,
            ),
            child: Row(children: [
              Expanded(child: Text(getTranslated(title, context)!, style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))),

              dateSelection ?
              InkWell(onTap: onPress ,
                child: Container(decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor, width: .25),
                    borderRadius: BorderRadius.circular(50)),
                  child: Padding(padding: const EdgeInsets.all(8.0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text((shop.shopModel != null && shop.shopModel!.vacationStartDate != null) ? shop.shopModel!.vacationStartDate!:'${getTranslated('start_date', context)}', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                          child: Icon(Icons.arrow_forward_rounded,size: Dimensions.iconSizeDefault,
                              color:  Theme.of(context).primaryColor)),
                      Text((shop.shopModel != null && shop.shopModel!.vacationEndDate != null)? shop.shopModel!.vacationEndDate! : '${getTranslated("end_date", context)}', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                    ],
                    ),
                  ),
                ),
              ):
              FlutterSwitch(
                value: mode!,
                width: 40,
                height: 27,
                activeColor: Theme.of(context).primaryColor,
                toggleSize: 20,
                padding: 2,
                onToggle: onTap!
              )

            ],),
          );
        }
    );
  }
}