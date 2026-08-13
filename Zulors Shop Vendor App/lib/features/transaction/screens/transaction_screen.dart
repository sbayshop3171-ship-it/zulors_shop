import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/transaction/widgets/transaction_shimmer_widget.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/transaction/controllers/transaction_controller.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/no_data_screen.dart';
import 'package:zulors_shop_vendor/features/transaction/widgets/transaction_widget.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {


  void _loadData(BuildContext context){
    Provider.of<TransactionController>(context, listen: false).getTransactionList(context, 'all','','');
    Provider.of<TransactionController>(context, listen: false).initMonthTypeList();
    Provider.of<TransactionController>(context, listen: false).initYearList();
  }

  double filterHeight = 45;


  TextEditingController searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadData(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async{
        Provider.of<TransactionController>(context, listen: false).getTransactionList(context, 'all','','');
      },
      child: Scaffold(
        appBar: CustomAppBarWidget(title: getTranslated('transactions', context), isAction: true),
        body: Consumer<TransactionController>(
          builder: (context, transactionProvider, child) {

            return Column(children: [SizedBox(height: 65,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: const [
                      TransactionTypeButton(text: 'all', index: 0),
                      TransactionTypeButton(text: 'pending', index: 1),
                      TransactionTypeButton(text: 'approved', index: 2),
                      TransactionTypeButton(text: 'denied', index: 3),
                    ],
                  )),

                Expanded(child: transactionProvider.transactionList != null ? transactionProvider.transactionList!.isNotEmpty ?

                 ListView.builder(
                     itemCount: transactionProvider.transactionList!.length,
                    itemBuilder: (context, index) => TransactionWidget(transactionModel: transactionProvider.transactionList![index]),
                 ) : const NoDataScreen() : const TransactionShimmerWidget(),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}

class TransactionTypeButton extends StatelessWidget {
  final String text;
  final int index;
  const TransactionTypeButton({super.key, required this.text, required this.index,});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: Dimensions.paddingSizeMedium),
        child: InkWell(
          onTap: (){
            Provider.of<TransactionController>(context, listen: false).setIndex(context, index);
          },
          child: Consumer<TransactionController>(builder: (context, transactionProvider, child) {
            return Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge,),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: transactionProvider.transactionTypeIndex == index ? Theme.of(context).primaryColor : Provider.of<ThemeController>(context).darkTheme ?
                ColorHelper.blendColors(Colors.white, Theme.of(context).highlightColor, 0.9) :
                Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
              ),
              child: Text(getTranslated(text, context)!, style: transactionProvider.transactionTypeIndex == index
                  ? titilliumBold.copyWith(color: transactionProvider.transactionTypeIndex == index
                  ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).textTheme.bodyLarge?.color):
              robotoRegular.copyWith(color: transactionProvider.transactionTypeIndex == index
                  ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).textTheme.bodyLarge?.color)),
            );
          },
          ),
        ),
      ),
    );
  }
}