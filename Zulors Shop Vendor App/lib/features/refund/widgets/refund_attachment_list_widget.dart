import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/features/refund/domain/models/refund_model.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';

import 'image_diaglog_widget.dart';

class RefundAttachmentListWidget extends StatelessWidget {
  final RefundModel? refundModel;
  const RefundAttachmentListWidget({super.key, this.refundModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: refundModel!.images!.length,
        itemBuilder: (BuildContext context, index){
          return refundModel!.images!.isNotEmpty ?
          InkWell(
            splashColor: Colors.transparent,
            onTap: () => showDialog(context: context, builder: (ctx)  => ImageDialogWidget(imageUrl: '${refundModel!.imagesFullUrl![index].path}')),
            child: Container(
              width: Dimensions.productImageSize,
              margin: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
              decoration:  BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black.withValues(alpha:0.07), width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeOrder)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeOrder)),
                child: CustomImageWidget(
                  image: '${refundModel!.imagesFullUrl![index].path}',
                  fit: BoxFit.cover,
                  width: Dimensions.productImageSize,
                  height: Dimensions.productImageSize,
                ),
              ),
            ),
          ) : const SizedBox();

        },),
    );
  }
}
