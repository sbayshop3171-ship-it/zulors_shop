import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/wallet/controllers/wallet_controller.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/profile/controllers/profile_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_edit_dialog_widget.dart';

class WithdrawBalanceWidget extends StatefulWidget {
  const WithdrawBalanceWidget({super.key});

  @override
  State<WithdrawBalanceWidget> createState() => _WithdrawBalanceWidgetState();
}

class _WithdrawBalanceWidgetState extends State<WithdrawBalanceWidget> {
  @override
  void initState() {
    Provider.of<WalletController>(context, listen: false).getWithdrawMethods(context);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final widthSize = MediaQuery.of(context).size.width;

    return Container(
      width: widthSize,
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall).copyWith(top: Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
      ),
      child: Stack(children: [

        Positioned(
          top: - 130,
          right: - 40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
        ),

        Consumer<ProfileController>(
            builder: (context, seller, child) {
              return Container(
                width: widthSize,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
                child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Image.asset(Images.cardWhite, height: Dimensions.logoHeight, width: Dimensions.logoHeight),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),


                  Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end, children: [

                    Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Text(getTranslated('balance_withdraw', context)!, style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).cardColor,
                      )),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Text(PriceConverter.convertPrice(context, seller.userInfoModel!.wallet != null ?
                      seller.userInfoModel!.wallet!.totalEarning ?? 0 : 0), style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeMaxLarge,
                        color: Theme.of(context).cardColor,
                      )),
                    ]),

                    const Spacer(),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    InkWell(
                      onTap: () => showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          context: context, builder: (_) => CustomEditDialogWidget(totalEarning: seller.userInfoModel!.wallet != null
                          ? seller.userInfoModel!.wallet!.totalEarning ?? 0 : 0,
                      )),
                      child: Container(height: 40, width: widthSize * 0.2,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                        ),
                        alignment: Alignment.center,
                        child: Text(getTranslated('withdraw', context)!, style:titilliumRegular.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: Dimensions.fontSizeDefault,
                        )),
                      ),
                    ),
                  ]),
                ]),
              );
            }
        ),
      ]),
    );
  }
}
