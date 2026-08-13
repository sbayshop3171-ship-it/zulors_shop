import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/refund/domain/models/refund_details_model.dart';
import 'package:zulors_shop_vendor/features/refund/domain/models/refund_model.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/refund/controllers/refund_controller.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/confirmation_dialog_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';

class ApprovedAndRejectWidget extends StatefulWidget {
  final RefundModel? refundModel;
  final int? orderDetailsId;
  const ApprovedAndRejectWidget({super.key, this.refundModel, this.orderDetailsId});

  @override
  State<ApprovedAndRejectWidget> createState() => _ApprovedAndRejectWidgetState();
}

class _ApprovedAndRejectWidgetState extends State<ApprovedAndRejectWidget> {
  bool approved = false;
  bool reject = false;
  final TextEditingController noteController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer<RefundController>(
        builder: (context,refundReq,_) {
          if(refundReq.refundDetailsModel != null){
            List<RefundStatus>? status =[];

            if(refundReq.refundDetailsModel?.refundRequest != null && refundReq.refundDetailsModel!.refundRequest!.isNotEmpty){
              status = refundReq.refundDetailsModel?.refundRequest![0].refundStatus;
            }

            if(status!.isNotEmpty){
              if(status[status.length-1].status == 'approved'){
                approved = true;
                reject = false;
              }else if(status[status.length-1].status == 'rejected'){
                approved = false;
                reject = true;
              }
            }
          }
          return Container(
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: ThemeShadow.getShadow(context),
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.fontSizeSmall, vertical: Dimensions.paddingSizeSmall),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                if(!reject)
                Expanded(
                  child: CustomButtonWidget(
                    buttonHeight: 50,
                    borderRadius: Dimensions.paddingSizeSmall,
                    btnTxt: getTranslated('reject', context),
                    fontColor: Colors.red,
                    backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.125),
                    onTap: (){
                      if(widget.refundModel!.customer == null){
                        showCustomSnackBarWidget(getTranslated('customer_account_was_deleted_you_cant_update_status', context), context);
                      }else{
                       //  Navigator.pop(context);
                        showDialog(context: context, builder: (BuildContext context){
                          return ConfirmationDialogWidget(icon:  Images.cross,
                              description: getTranslated('are_you_sure_want_to_reject', context),
                              note: noteController,
                              refund: true,
                              onYesPressed: () {
                                if(noteController.text.trim().isEmpty) {
                                  showCustomToast(isSuccess: false, message: getTranslated('note_required', context) ?? '', context: context);
                                } else{
                                  refundReq.isLoading ?
                                  const Center(child: CircularProgressIndicator()):refundReq.updateRefundStatus(context, widget.refundModel!.id, 'rejected', noteController.text.trim()).then((value) {
                                    if(value.response?.statusCode ==200) {
                                      Provider.of<RefundController>(Get.context!, listen: false).getRefundReqInfo(Get.context!, widget.orderDetailsId);
                                      Provider.of<RefundController>(Get.context!, listen: false).getRefundList(Get.context!);
                                      Navigator.pop(Get.context!);
                                      noteController.clear();
                                    }
                                  });
                                }
                              }
                          );
                        });
                      }
                    },
                  ),
                ),

                if(!reject && !approved)
                const SizedBox(width: Dimensions.paddingSizeDefault),

                if(!approved)
                  Expanded(
                    child: CustomButtonWidget(
                      buttonHeight: 50,
                      borderRadius: Dimensions.paddingSizeSmall,
                      btnTxt: getTranslated('approve', context),
                      backgroundColor: Theme.of(context).primaryColor,
                      onTap: (){
                        if(widget.refundModel!.customer == null){
                          showCustomSnackBarWidget(getTranslated('customer_account_was_deleted_you_cant_update_status', context), context);
                        }else{
                          // Navigator.pop(context);
                          showDialog(context: context,barrierDismissible: false, builder: (BuildContext context){
                            return ConfirmationDialogWidget(
                              icon:  Images.okIcon,
                              description: getTranslated('are_you_sure_want_to_approve', context),
                              note: noteController,
                              refund: true,
                              onYesPressed: () {
                                refundReq.isLoading?
                                const Center(child: CircularProgressIndicator()):refundReq.updateRefundStatus(context, widget.refundModel!.id, 'approved',noteController.text.trim()).then((value) {
                                  if(value.response!.statusCode == 200) {
                                    Provider.of<RefundController>(Get.context!, listen: false).getRefundReqInfo(Get.context!, widget.orderDetailsId);
                                    Provider.of<RefundController>(Get.context!, listen: false).getRefundList(Get.context!);
                                    Navigator.pop(Get.context!);
                                    noteController.clear();
                                  }
                                });
                              });
                          });
                        }},
                    ),
                  ),
              ],
            ),
          );
        }
    );
  }
}
