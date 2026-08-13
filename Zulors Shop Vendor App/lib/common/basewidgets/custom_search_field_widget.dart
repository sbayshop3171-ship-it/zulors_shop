import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/localization/controllers/localization_controller.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class CustomSearchFieldWidget extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final String prefix;
  final Function iconPressed;
  final Function(String text)? onSubmit;
  final Function? onChanged;
  final Function? filterAction;
  final bool isFilter;
  const CustomSearchFieldWidget({super.key,
    required this.controller,
    required this.hint,
    required this.prefix,
    required this.iconPressed,
    this.onSubmit,
    this.onChanged,
    this.filterAction,
    this.isFilter = false,
  });

  @override
  State<CustomSearchFieldWidget> createState() => _CustomSearchFieldWidgetState();
}

class _CustomSearchFieldWidgetState extends State<CustomSearchFieldWidget> {
  @override
  Widget build(BuildContext context) {
    ThemeController themeProvider = Provider.of<ThemeController>(context, listen: false);
    return Row(children: [
      Expanded(
        child: TextField(
          controller: widget.controller,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).disabledColor.withValues(alpha:.5)),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
            ),
            filled: true,
            fillColor: themeProvider.darkTheme ?
            Theme.of(context).primaryColor.withValues(alpha:.30)
            : Theme.of(context).primaryColor.withValues(alpha:.07),
            isDense: true,
            focusedBorder:OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: .70),
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
            ),
            suffixIcon: InkWell(
              onTap: widget.iconPressed(),
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeMedium),
                child: SizedBox(width: Dimensions.iconSizeExtraSmall,  child: Image.asset(widget.prefix)),
              ),
            ),
          ),
          onSubmitted: widget.onSubmit,
          onChanged: widget.onChanged as void Function(String)?,
        ),
      ),

      
      widget.isFilter ? Padding(
          padding:  EdgeInsets.only(left :  Provider.of<LocalizationController>(context, listen: false).isLtr? Dimensions.paddingSizeExtraSmall : 0,
              right :  Provider.of<LocalizationController>(context, listen: false).isLtr? 0 : Dimensions.paddingSizeExtraSmall),
         child: GestureDetector(
            onTap: widget.filterAction as void Function()?,
            child: Container(decoration: BoxDecoration(
             color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeMedium),
              child: Image.asset(Images.filterIcon, width: Dimensions.paddingSizeLarge)),
        ),
      ) : const SizedBox(),
    ],);
  }
}
