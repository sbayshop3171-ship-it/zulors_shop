import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/restock/controllers/restock_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class RestockCalenderWidget extends StatefulWidget {
  const RestockCalenderWidget({super.key});


  @override
  State<RestockCalenderWidget> createState() => RestockCalenderWidgetState();
}

class RestockCalenderWidgetState extends State<RestockCalenderWidget> {

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, _) {
        return Consumer<RestockController>(
            builder: (context,restockController,_) {
              return Dialog(
                child: SizedBox(
                  height: 400,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                    child: Container(
                      color: themeController.darkTheme ? Theme.of(context).dividerColor : Theme.of(context).canvasColor,
                      child: SfDateRangePicker(
                        confirmText: getTranslated('ok', context)!,
                        showActionButtons: true,
                        cancelText: getTranslated('cancel', context)!,
                        onCancel: ()=> Navigator.pop(context),
                        onSubmit: (value){
                          if(value is PickerDateRange) {
                            restockController.selectDate(
                              context,
                              DateFormat('yyyy-MM-dd').format(value.startDate!),
                              DateFormat('yyyy-MM-dd').format(value.endDate ?? value.startDate!),
                            );
                            Navigator.pop(context);
                          }
                        },
                        todayHighlightColor: Theme.of(context).primaryColor,
                        selectionMode: DateRangePickerSelectionMode.range,
                        rangeSelectionColor: Theme.of(context).primaryColor.withValues(alpha:.25),
                        view: DateRangePickerView.month,
                        startRangeSelectionColor: Theme.of(context).primaryColor,
                        endRangeSelectionColor: Theme.of(context).primaryColor,
                        initialSelectedRange: PickerDateRange(
                            restockController.startDate != null? DateTime.parse(restockController.startDate!): DateTime.now().subtract(const Duration(days: 2)),
                            restockController.endDate != null? DateTime.parse(restockController.endDate!): DateTime.now().add(const Duration(days: 2))),
                      ),),
                  ),
                ),
              );
            }
        );
      }
    );
  }
}
