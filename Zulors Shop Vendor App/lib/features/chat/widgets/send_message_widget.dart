import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/chat/domain/models/message_body.dart';
import 'package:zulors_shop_vendor/features/chat/widgets/custom_image_pick_bottom_sheet.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/chat/controllers/chat_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:flutter/foundation.dart' as foundation;


class SendMessageWidget extends StatefulWidget {
  final int? id;
  const SendMessageWidget({super.key, this.id});

  @override
  State<SendMessageWidget> createState() => _SendMessageWidgetState();
}



class _SendMessageWidgetState extends State<SendMessageWidget> {
  final TextEditingController _controller = TextEditingController();
  bool emojiPicker = false;

  bool _isSendingButtonActive(ChatController chatController){
    bool mediaCheck =  !chatController.pickedImageCrossMaxLength && !chatController.pickedFIleCrossMaxLength;
    bool textExist = (_controller.text.trim().isNotEmpty || chatController.isSendButtonActive);
    bool limitCheck = !chatController.pickedFIleCrossMaxLimit && !chatController.singleFIleCrossMaxLimit;
    return textExist && mediaCheck && limitCheck;
  }

  void _toggleSendingButtonActive(ChatController chatController, String newText){
    bool isMediaActive = (chatController.pickedMediaFileModelList?.isNotEmpty ?? false) || (chatController.pickedFiles?.isNotEmpty ?? false);
    if(!isMediaActive){
      if(newText.isNotEmpty && !chatController.isSendButtonActive ) {
        chatController.toggleSendButtonActivity();
      }else if(newText.isEmpty && chatController.isSendButtonActive) {
        chatController.toggleSendButtonActivity();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, chatController, _) {
        return ColoredBox(
          color: Theme.of(context).primaryColor.withValues(alpha:0.1),
          child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: SizedBox(height: 40,
                  child: Padding(padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                    child: Row(children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).primaryColor,width: 1),
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: TextField(
                            controller: _controller,
                            style: titilliumRegular,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            expands: true,
                            onTap: (){
                              setState(() {
                                emojiPicker = false;
                                chatController.setEmojiPickerValue(false, notify: true);
                              });
                            },
                            decoration: InputDecoration(
                              hintText: getTranslated('type_here', context),
                              hintStyle: titilliumRegular.copyWith(color: Theme.of(context).hintColor),
                              border: InputBorder.none,

                              prefixIcon: GestureDetector(onTap: (){
                                setState(() {
                                  chatController.setEmojiPickerValue(!emojiPicker, notify: true);
                                  emojiPicker = !emojiPicker;
                                  FocusManager.instance.primaryFocus?.unfocus();
                                });
                              },
                                child: Padding(padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Image.asset(Images.emoji),),
                              ),

                              suffixIcon: Row( mainAxisSize : MainAxisSize.min, children: [
                                  GestureDetector(onTap: ()=> chatController.pickOtherFile(false),
                                    child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                      child: Image.asset(Images.file, height: 30, width: 30)),
                                  ),
                                  InkWell(onTap: ()=> showModalBottomSheet(context: context, builder: (context) => CustomImagePickBottomSheet(chatController)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal:  Dimensions.paddingSizeExtraSmall),
                                      child: Image.asset(Images.attachment, height: 30, width: 30, color: Theme.of(context).primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onChanged: (String newText) => _toggleSendingButtonActive(chatController, newText),
                          ),
                        ),
                      ),

                      const SizedBox(width: Dimensions.paddingSizeDefault),

                      chatController.isLoading? const Center(child: SizedBox(width: 30,height: 30,child: CircularProgressIndicator())):
                      GestureDetector(
                        onTap: () {
                          if(_isSendingButtonActive(chatController)){
                            MessageBody messageBody = MessageBody(sellerId: widget.id, message: _controller.text.trim());
                            chatController.sendMessage(messageBody).then((value){
                              if(value.statusCode == 200){
                                _controller.clear();
                                chatController.toggleSendButtonActivity();
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(color: _isSendingButtonActive(chatController) ? Theme.of(context).primaryColor : Theme.of(context).hintColor, width: 2),
                          ),
                          child: SizedBox(width: Dimensions.iconSizeLarge,height: Dimensions.iconSizeLarge,
                            child: Image.asset(Images.send,
                              color: _isSendingButtonActive(chatController) ? Theme.of(context).primaryColor : Theme.of(context).hintColor),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),

              if(emojiPicker)
                SizedBox(height: 250,
                  child: EmojiPicker(
                    onBackspacePressed: () {
                    },
                    textEditingController: _controller,
                    config: Config(
                      height: 256,
                      checkPlatformCompatibility: true,
                      emojiViewConfig: EmojiViewConfig(
                        // Issue: https://github.com/flutter/flutter/issues/28894
                        emojiSizeMax: 28 *
                            (foundation.defaultTargetPlatform ==
                                TargetPlatform.iOS
                                ? 1.2
                                : 1.0),
                      ),
                      skinToneConfig: const SkinToneConfig(),
                      categoryViewConfig: const CategoryViewConfig(),
                      bottomActionBarConfig: const BottomActionBarConfig(),
                      searchViewConfig: const SearchViewConfig(),
                    ),
                  ),
                ),
            ],
          ),
        );
      }
    );
  }
}
