import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/features/pos/screens/hold_order_page.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class PosAppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const PosAppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
            actions: [

              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HoldOrderScreen()));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,top: 5,
                         child: Consumer<CartController>(
                           builder: (context, cartController, _ ){
                             return Container(
                                height: 18, width: 18,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red
                                ),
                                child:  Center(
                                  child: Text((cartController.customerCartList.length).toString(),
                                  style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor)
                                  )
                                ),
                            );
                           }
                         )),

                      Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Container(
                          height: 25, width: 25,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).hintColor.withValues(alpha:0.25)
                          ),
                          child: const Center(
                            child: Icon(Icons.pause, size: 20),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],


            backgroundColor: Theme.of(context).cardColor,
            toolbarHeight: 50,
            iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge?.color),
            automaticallyImplyLeading: false,
            title: Text(getTranslated('billing_section', context)!, style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 1,textAlign: TextAlign.start, overflow: TextOverflow.ellipsis),

            centerTitle: false,
            excludeHeaderSemantics: true,
            titleSpacing: 0,
            elevation: 1,
            clipBehavior: Clip.none,
            shadowColor: Theme.of(context).primaryColor.withValues(alpha:.1),

            leadingWidth: 50,
            leading:  Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Image.asset(Images.billingSection, height: 30)),

      )
    );
  }

  @override
  Size get preferredSize =>  Size(MediaQuery.of(Get.context!).size.width, 50);
}