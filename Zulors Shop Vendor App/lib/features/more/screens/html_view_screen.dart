import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/business_pages_model.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';

class HtmlViewScreen extends StatelessWidget {
  final BusinessPageModel? page;
  const HtmlViewScreen({super.key, required this.page});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBarWidget(title: page?.title ?? ''),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Column(
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: SizedBox(
                        height: 70,
                        width: double.infinity,
                        child: CustomImageWidget(
                          fit: BoxFit.cover,
                          image: page?.bannerFullUrl?.path ?? "",
                        ),
                      ),
                    ),
                    // const SizedBox(height: Dimensions.paddingSizeSmall),

                    Html(
                      style: {
                        "body": Style(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: FontSize.medium,
                        ),
                      },
                      data: page?.description ?? '',
                    ),

                  ],
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
}
