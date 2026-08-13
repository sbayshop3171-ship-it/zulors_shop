import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_asset_image_widget.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class ManagementCardWidget extends StatelessWidget {
  final String name;
  final String? description;
  final String image;
  final Widget screenToRoute;
  const ManagementCardWidget({super.key, required this.name, this.description, required this.image, required this.screenToRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
        )],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
        Padding(
          padding: EdgeInsets.all(Dimensions.fontSizeLarge),
          child: CustomAssetImageWidget(image, height: Dimensions.logoHeight, width: Dimensions.logoHeight, color: Theme.of(context).primaryColor),
        ),
        
        Container(
          padding: EdgeInsets.all(Dimensions.fontSizeLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).hintColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(Dimensions.paddingSizeSmall), bottomRight: Radius.circular(Dimensions.paddingSizeSmall)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                Text(name, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)),
                Text(description ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor))
              ]),
            ),
            SizedBox(width: Dimensions.paddingSizeSmall),

            InkWell(
              splashColor: Colors.transparent,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screenToRoute)),
              child: Container(
                  padding: EdgeInsets.all(Dimensions.paddingEye),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    )],
                  ),
                child: Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor, size: Dimensions.paddingSizeDefault),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
