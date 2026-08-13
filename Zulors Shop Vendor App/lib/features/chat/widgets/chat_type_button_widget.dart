import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/chat/controllers/chat_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';


class ChatTypeButtonWidget extends StatelessWidget {
  final String? text;
  final int index;
  final Function? onPressEvent;
  const ChatTypeButtonWidget({super.key, required this.text, required this.index, this.onPressEvent});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: (){
        if(onPressEvent != null) {
          onPressEvent!();
        }
        Provider.of<ChatController>(context, listen: false).setUserTypeIndex(context, index);
      },
      child: Consumer<ChatController>(builder: (context, chat,_) {
        return Column(mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(text!, style:
            robotoRegular.copyWith(color: chat.userTypeIndex == index ?
            Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(5)
              ),
                width: chat.userTypeIndex == index ? 80 : 0,
                height: chat.userTypeIndex == index ? 2 : 2,
                )
          ],
        );
      },
      ),
    );
  }
}