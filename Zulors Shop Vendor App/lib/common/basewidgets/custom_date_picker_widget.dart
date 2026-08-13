import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';


class CustomDatePickerWidget extends StatefulWidget {
  final String? title;
  final String? text;
  final String? image;
  final bool requiredField;
  final bool fromClearance;
  final bool fromVacation;
  final Function? selectDate;
  final Color? borderColor;
  const CustomDatePickerWidget({super.key, this.title,this.text,this.image, this.fromClearance = false, this.fromVacation = false, this.requiredField = false,this.selectDate, this.borderColor});

  @override
  State<CustomDatePickerWidget> createState() => _CustomDatePickerWidgetState();
}

class _CustomDatePickerWidgetState extends State<CustomDatePickerWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.only(left: !widget.fromClearance ? Dimensions.paddingSizeDefault : 0,
        right: !widget.fromClearance ?  Dimensions.paddingSizeDefault : 0),

      child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [

        RichText(
          text: TextSpan(
            text: widget.title, style:  widget.fromClearance ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color) : robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
            children: <TextSpan>[
              widget.requiredField ? TextSpan(text: '  *', style: robotoBold.copyWith(color: Colors.red)) : const TextSpan(),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall-1, horizontal: Dimensions.paddingSizeSmall-1),
          decoration: BoxDecoration(
            border: Border.all(color: widget.borderColor ?? Theme.of(context).primaryColor, width: widget.fromVacation ? 1.5 : widget.fromClearance ? .600 : 0.1),
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
          ),
          child: InkWell(
            onTap: widget.selectDate as void Function()?,
            child: Row( mainAxisAlignment: MainAxisAlignment.start,children: [
              SizedBox(width: 20,height: 20,child: Image.asset(widget.image!, color: widget.fromClearance ? Theme.of(context).primaryColor : null)),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(widget.text!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).textTheme.bodyLarge!.color)),
            ]),
          ),
        ),
      ],),
    );
  }
}
