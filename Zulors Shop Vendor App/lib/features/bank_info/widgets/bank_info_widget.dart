import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class BankInfoWidget extends StatelessWidget {
  final String? name;
  final String? bank;
  final String? branch;
  final String? accountNo;
  const BankInfoWidget({super.key, this.name, this.bank, this.branch, this.accountNo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Container(width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage(Images.bankInfoBg),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
        child: Stack( children: [
            // Positioned(
            //   child: Align(
            //     alignment: Alignment.centerRight,
            //     child: Container(width: MediaQuery.of(context).size.width/3,
            //       height: 200,
            //       decoration: BoxDecoration(
            //           color: Theme.of(context).cardColor.withValues(alpha:.05),
            //           borderRadius: const BorderRadius.only(topLeft: Radius.circular(100), bottomLeft: Radius.circular(100) ))))),
            //
            // Positioned(
            //   child: Align(
            //     alignment: Alignment.centerRight,
            //     child: Container(width: MediaQuery.of(context).size.width/4,
            //       height: 200,
            //       decoration: BoxDecoration(
            //           color: Theme.of(context).cardColor.withValues(alpha:.05),
            //           borderRadius: const BorderRadius.only(topLeft: Radius.circular(100), bottomLeft: Radius.circular(100) ))))),

            Column(children: [
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Padding(padding:  const EdgeInsets.only(right: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault),
                    child: SizedBox(width: 40, child: Image.asset(Images.accountHolder))),

                Expanded(child: CardItem(title: 'ac_holder',value: name)),
             ]),

              Divider(color: Theme.of(context).cardColor.withValues(alpha:.5),thickness: 1.5),

              CardItem(title: 'bank', value: bank),
              CardItem(title: 'branch', value: branch),
              CardItem(title: 'account_no' ,value: accountNo),
              const SizedBox(height: Dimensions.paddingSizeDefault),

            ]),


          ],),),
    );
  }
}

class CardItem extends StatelessWidget {
  final String? title;
  final String? value;
  const CardItem({super.key, this.title, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall,
          Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall),
      child: Row( children: [
          Text('${getTranslated(title, context)} : ',
              style: robotoRegular.copyWith(
              // color: Provider.of<ThemeController>(context, listen: false).darkTheme?
              // Theme.of(context).hintColor: Theme.of(context).cardColor
              color: Theme.of(context).textTheme.bodyLarge?.color
          )),

          Expanded(
            child: Text(value!, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
          ),
        ],
      ),
    );
  }
}