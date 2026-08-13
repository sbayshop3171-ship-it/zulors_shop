import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class InvoiceElementViewWidget extends StatelessWidget {
  final bool isBold;
  final String? title;
  final String? serial;
  final String? quantity;
  final String? price;
  const InvoiceElementViewWidget({
    super.key,
    this.serial,
    this.isBold = false,
    this.title,
    this.quantity,
    this.price,
  });

  @override
  Widget build(BuildContext context) {
    return  Row(children: [
      Expanded(flex: 5,
        child: serial != null ? Row(mainAxisAlignment: MainAxisAlignment.start,children: [
          _textView(context, serial!, isBold),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          _textView(context, title!, isBold),

        ],) : Text(title!, style: isBold ? robotoBold.copyWith(
          color: Theme.of(context).primaryColor,
          fontSize: Dimensions.fontSizeLarge,
        ) : robotoRegular.copyWith(color: Theme.of(context).hintColor)),
      ),

      Expanded(flex: 3,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          quantity != null ? _textView(context, quantity!, isBold) : const SizedBox(),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          Text(price!, style: isBold ? robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color,
          ) : robotoRegular.copyWith(color:  Provider.of<ThemeController>(context, listen: false).darkTheme ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor)),
        ],),
      ),
    ],);
  }

  Text _textView(BuildContext context,String text, bool isBold) {
    return Text(text, style: isBold ? robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color
    ) : robotoRegular.copyWith(color: Provider.of<ThemeController>(context, listen: false).darkTheme ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor));
  }
}
