import 'package:flutter/material.dart';
import 'package:zulors_shop/common/basewidget/title_row_widget.dart';
import 'package:zulors_shop/features/search_product/controllers/search_product_controller.dart';
import 'package:zulors_shop/helper/responsive_helper.dart';
import 'package:zulors_shop/helper/route_healper.dart';
import 'package:zulors_shop/localization/controllers/localization_controller.dart';
import 'package:zulors_shop/localization/language_constrants.dart';
import 'package:zulors_shop/theme/controllers/theme_controller.dart';
import 'package:zulors_shop/utill/dimensions.dart';
import 'package:provider/provider.dart';

class PublicatioinHouseWidget extends StatelessWidget {
  final bool isHomePage;
  const PublicatioinHouseWidget({super.key, required this.isHomePage});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProductController>(
      builder: (context, searchProductController, child) {

        return (searchProductController.publishingHouseList != null && searchProductController.publishingHouseList!.isNotEmpty) ?
          Column(
            children: [
              TitleRowWidget(
                title: getTranslated('publication_house', context),
                onTap: () {}
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              SingleChildScrollView(scrollDirection: Axis.horizontal,
                  child: Row(children: List<Widget>.generate(searchProductController.publishingHouseList!.length, (index){
                    return InkWell(splashColor: Colors.transparent, highlightColor: Colors.transparent,
                      onTap: () {
                        RouterHelper.getSearchRoute(action: RouteAction.push);
                        Provider.of<SearchProductController>(context, listen: false).checkedTogglePublishingHouse(index, false, fromHomePage: true);
                        Provider.of<SearchProductController>(context, listen: false).searchProduct( query : '', offset:1,  publishingIds: Provider.of<SearchProductController>(context, listen: false).publishingHouseIds.toString());

                        // Navigator.push(context, MaterialPageRoute(builder: (_) =>   ));
                      },
                      child: Padding(padding: EdgeInsets.only(left : Provider.of<LocalizationController>(context, listen: false).isLtr ?
                      Dimensions.paddingSizeDefault : 0,
                        // right: searchProductController.publishingHouseList!.length == searchProductController.publishingHouseList.indexOf(brand) + 1? Dimensions.paddingSizeDefault : Provider.of<LocalizationController>(context, listen: false).isLtr ? 0 : Dimensions.paddingSizeDefault
                      ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          Container(width: ResponsiveHelper.isTab(context)? 120 :50, height: ResponsiveHelper.isTab(context)? 120 :50,
                            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(5)),
                                color: Theme.of(context).highlightColor,
                                boxShadow: Provider.of<ThemeController>(context, listen: false).darkTheme ?
                                null :[BoxShadow(color: Colors.grey.withValues(alpha:0.12), spreadRadius: 1, blurRadius: 1, offset: const Offset(0, 1))]),
                            child: Text(searchProductController.publishingHouseList![index].name ?? ''),
                          ),
                        ],
                        ),
                      ),
                    );
                  }
                )
              )),

              const SizedBox(height: Dimensions.paddingSizeSmall),
            ],
          )
        : const SizedBox();

      },
    );
  }
}