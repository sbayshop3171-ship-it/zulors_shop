import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/chat/domain/models/chat_model.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/features/chat/controllers/chat_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/chat/screens/chat_screen.dart';

class ChatCardWidget extends StatelessWidget {
  final Chat? chat;
  final Function callBack;
  const ChatCardWidget({super.key, this.chat, required this.callBack});

  @override
  Widget build(BuildContext context) {

    int? id = Provider.of<ChatController>(context, listen: false).userTypeIndex == 0 ?
    chat!.customer?.id?? -1 : chat!.deliveryManId;

    String? image = Provider.of<ChatController>(context, listen: false).userTypeIndex == 0 ?
    chat!.customer != null? chat?.customer?.imageFullUrl?.path: '' : chat!.deliveryMan?.imageFullUrl?.path;

    String name = Provider.of<ChatController>(context, listen: false).userTypeIndex == 0 ?
    chat!.customer != null?
    '${chat!.customer?.fName} ${chat!.customer?.lName}' :'Deleted' :
    '${chat!.deliveryMan?.fName??'Deliveryman'} ${chat!.deliveryMan?.lName??'Deleted'}';


    return Padding(
      padding:  const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: (){

          Provider.of<ChatController>(context, listen: false).seenMessage( context, id, id);
          callBack();

          if(name.trim() == "Deleted"){
            showCustomSnackBarWidget('Customer was deleted', context,  sanckBarType: SnackBarType.success);
          }else{
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return ChatScreen(userId: id, name: name);
            }));
          }
        },
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            color: (chat?.seenBySeller ?? false)  ? null : Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [

            ClipRRect(borderRadius: BorderRadius.circular(100),
              child: CachedNetworkImage(
                errorWidget: (ctx, url ,err )=>Image.asset(Images.placeholderImage,
                  height: Dimensions.chatImage, width: Dimensions.chatImage, fit: BoxFit.cover,),
                placeholder: (ctx, url )=>Image.asset(Images.placeholderImage),
                imageUrl: '$image',
                fit: BoxFit.cover, height: Dimensions.chatImage, width: Dimensions.chatImage,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall,),

            Expanded(
              child: Column(crossAxisAlignment:CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: titilliumSemiBold.copyWith(
                      color: (chat?.seenBySeller ?? false)
                          ? Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5)
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    )),

                    Text(
                      DateConverter.customTime(DateTime.parse(chat!.createdAt!)),
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center,children: [

                  Flexible(
                    child: Text( (chat!.message == null && chat!.attachment != null) ? getTranslated('sent_attachment', context)! : chat!.message??'',
                      maxLines: 2,overflow: TextOverflow.ellipsis,
                      style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                          color: (chat?.seenBySeller ?? false) ? Theme.of(context).hintColor : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),

                  if((chat?.unseenMessageCount ?? 0 )> 0)
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                  if((chat?.unseenMessageCount ?? 0 )> 0)
                    CircleAvatar(radius: 12, backgroundColor: Theme.of(context).primaryColor,
                        child: Text('${chat?.unseenMessageCount ?? 0}', style: titilliumRegular.copyWith(
                            color: Theme.of(context).cardColor,
                            fontSize: Dimensions.fontSizeSmall,
                        )),
                    )
                ]),
              ]),
            )
          ]),
        ),
      ),
    );
  }
}
