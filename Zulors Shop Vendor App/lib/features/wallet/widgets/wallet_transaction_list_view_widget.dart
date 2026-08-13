import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/features/transaction/controllers/transaction_controller.dart';
import 'package:zulors_shop_vendor/features/transaction/widgets/transaction_widget.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';

class WalletTransactionListViewWidget extends StatelessWidget {
  final TransactionController? transactionProvider;
  const WalletTransactionListViewWidget({super.key, this.transactionProvider});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactionProvider!.transactionList!.length,
      itemBuilder: (context, index) => TransactionWidget(transactionModel: transactionProvider!.transactionList![index]),
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: Dimensions.paddingSizeExtraSmall),
    );
  }
}
