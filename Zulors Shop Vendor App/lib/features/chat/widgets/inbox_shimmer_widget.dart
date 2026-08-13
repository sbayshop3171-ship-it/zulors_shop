
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zulors_shop_vendor/features/chat/controllers/chat_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';



class InboxShimmerWidget extends StatelessWidget {
  const InboxShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: 15,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            enabled: Provider.of<ChatController>(context).chatList == null,
            child: Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: Row(children: [
                const CircleAvatar(radius: 30, child: Icon(Icons.person)),
      
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Column(children: [
                      Container(height: 15, color: Theme.of(context).colorScheme.secondaryContainer),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Container(height: 15, color: Theme.of(context).colorScheme.secondaryContainer),
                    ]),
                  ),
                ),
      
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(height: 10, width: 30, color: Theme.of(context).colorScheme.secondaryContainer),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
      
                  Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                  ),
      
                ])
              ]),
            ),
          );
        },
      ),
    );
  }
}