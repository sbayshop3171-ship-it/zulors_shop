import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/review/domain/models/review_model.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/review/controllers/product_review_controller.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/features/review/widgets/review_widget.dart';


class ReviewFullViewScreen extends StatelessWidget {
  final ReviewModel? reviewModel;
  final bool? isDetails;
  final int? index;
  const ReviewFullViewScreen({super.key, this.reviewModel, this.isDetails, this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title : getTranslated('review_details', context), isAction: true, isSwitch: true,
        index: index,
        reviewSwitch: true,
        switchAction: (value){
          if(value){
            Provider.of<ProductReviewController>(context, listen: false).reviewStatusOnOff(context, reviewModel!.id, 1, index);
          }else{
            Provider.of<ProductReviewController>(context, listen: false).reviewStatusOnOff(context, reviewModel!.id, 0, index);
          }
      },),
      body: ReviewWidget(reviewModel: reviewModel, isDetails: isDetails),
    );
  }
}
