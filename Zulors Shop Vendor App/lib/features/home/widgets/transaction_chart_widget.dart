import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zulors_shop_vendor/features/home/widgets/empty_earning_state_widget.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/bank_info/controllers/bank_info_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TransactionChart extends StatefulWidget {

  const TransactionChart({super.key});

  @override
  State<StatefulWidget> createState() => TransactionChartState();
}

class TransactionChartState extends State<TransactionChart> {
  bool isEarningEmpty = false;
  final Color leftBarColor = const Color(0xff4E9BF0);
  final Color rightBarColor = const Color(0xFFF4BE37);
  final double width = 5;

  final List<String> weeks = ['','Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
  final List<String> months = ['','Jan','Feb','Mar','Apr','May','June','July','Aug','Sep','Oct','Nov','Dec'];
  List<ChartData> _expanseChartList = [];

  List<ChartData> _incomeChartList = [];


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    Color earningColor = const Color(0xFF1455AC);
    Color comisssionColor = const Color(0xFFF4BE37).withValues(alpha:.5);
    return Consumer<BankInfoController>(
      builder: (context,bankInfoProvider, _) {
        isEarningEmpty = !(bankInfoProvider.lim > 1);

        List<double> earnings = [];
        List<double> commissions = [];
        if(bankInfoProvider.userCommissions != null && bankInfoProvider.userEarnings != null){
          for(double? earn in bankInfoProvider.userCommissions!) {
            earnings.add(PriceConverter.convertAmount(earn!, context));
          }
          for(double? commission in bankInfoProvider.userEarnings!) {
            commissions.add(PriceConverter.convertAmount(commission!, context));
          }
        }


        if(earnings.length < 9){

          _expanseChartList = commissions.asMap().entries.map((e) {
            return ChartData(weeks[e.key.toInt()], e.value);
          }).toList();

          _incomeChartList = earnings.asMap().entries.map((e) {
            return ChartData(weeks[e.key.toInt()], e.value);
          }).toList();

        }else if( earnings.length < 15){
          _expanseChartList = commissions.asMap().entries.map((e) {
            return ChartData(months[e.key.toInt()], e.value);
          }).toList();

          _incomeChartList = earnings.asMap().entries.map((e) {
            return ChartData(months[e.key.toInt()], e.value);
          }).toList();
        }else{
          _expanseChartList = commissions.asMap().entries.map((e) {
            return ChartData(e.key.toString(), e.value);
          }).toList();

          _incomeChartList = earnings.asMap().entries.map((e) {
            return ChartData(e.key.toString(), e.value);
          }).toList();
        }

        return AspectRatio(
          aspectRatio: isEarningEmpty ? 1.3 : 1,
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingEye),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[

                    Row(crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      Container(width: Dimensions.iconSizeLarge,height: Dimensions.iconSizeLarge ,
                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                          child: Image.asset(Images.monthlyEarning)),
                      const SizedBox(width: Dimensions.paddingSizeSmall,),

                      Text(getTranslated('earning_statistic', context)!, style: robotoBold.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: Dimensions.fontSizeDefault),),

                        const Expanded(child: SizedBox(width: Dimensions.paddingSizeExtraLarge,)),
                        Container(
                          height: 50,width: 120,
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            border: Border.all(width: .7,color: Theme.of(context).hintColor.withValues(alpha:.3)),
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),

                          ),
                          child: DropdownButton<String>(
                            value: bankInfoProvider.revenueFilterTypeIndex == 0 ? 'this_year' : bankInfoProvider.revenueFilterTypeIndex == 1 ?  'this_month' : 'this_week',
                            items: <String>['this_year', 'this_month', 'this_week' ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(getTranslated(value, context)!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),),
                              );
                            }).toList(),
                            onChanged: (value) {
                              bankInfoProvider.setRevenueFilterName(context,value, true);
                              bankInfoProvider.setRevenueFilterType(value == 'this_year' ? 0 : value == 'this_month'? 1:2, true);
                            },
                            isExpanded: true,
                            underline: const SizedBox(),
                          ),
                        ),

                    ],),
                    const SizedBox(height: Dimensions.paddingSizeSmall,),

                    Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                      children: [Row(children: [
                         Icon(Icons.circle,size: Dimensions.iconSizeSmall,
                            color: earningColor),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                        Text(getTranslated('your_earnings', context)!,
                          style: robotoSmallTitleRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: Dimensions.fontSizeDefault),),],),

                        const SizedBox(width : Dimensions.paddingSizeSmall,),

                        Row(children: [
                          Icon(Icons.circle,size: Dimensions.iconSizeSmall,
                              color: comisssionColor),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                          Text(getTranslated('commission_given', context)!,
                               style: robotoSmallTitleRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color,
                                   fontSize: Dimensions.fontSizeSmall),
                        ),
                           ],
                         ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: isEarningEmpty ? Dimensions.paddingSizeSmall : 38),

                (!isEarningEmpty) ?
                Expanded(
                  child: SfCartesianChart(
                    tooltipBehavior: TooltipBehavior(enable: true),
                    primaryXAxis: const CategoryAxis(),
                    primaryYAxis: const NumericAxis(),
                    series:[
                      LineSeries<ChartData, String>(
                        color: comisssionColor,
                        dataSource: _incomeChartList,
                        xValueMapper: (ChartData data,_)=> data.x,
                        yValueMapper: (ChartData data,_)=> data.y,
                      ),
                      LineSeries<ChartData, String>(
                        color: earningColor,
                        dataSource: _expanseChartList,
                        xValueMapper: (ChartData data,_)=> data.x,
                        yValueMapper: (ChartData data,_)=> data.y,
                      ),
                    ],
                  ),
                ) : const EmptyEarningStateWidget(),
                SizedBox(height: isEarningEmpty ? 0 : Dimensions.paddingSize),
              ],
            ),
          ),
        );
      }
    );
  }
}

class ChartData{
  String x;
  double y;
  ChartData(this.x,this.y);
}

List<Color> gradientColors = [
  const Color(0xFF1B7FED),
  const Color(0xff4560ad),
];

List<Color> commissionGradientColors = [
  const Color(0xFFF4BE37),
  const Color(0xFFF4BE37),
];



class EarningStatisticsShimmer extends StatelessWidget {
  final bool isDarkMode;
  const EarningStatisticsShimmer({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.secondaryContainer;

    final baseColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[500]! : Colors.grey[100]!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(width: 36, height: 36, color: shimmerColor),
                const SizedBox(width: 12),
                Container(height: 14, width: 120, color: shimmerColor),
                const Spacer(),
                Container(height: 50, width: 120, color: shimmerColor),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(height: 10, width: 100, color: shimmerColor),
                ]),
                const SizedBox(width: 12),
                Row(children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(height: 10, width: 100, color: shimmerColor),
                ]),
              ],
            ),
            const SizedBox(height: 38),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

