import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:zulors_shop_vendor/features/ai/controllers/ai_controller.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';


class GenerateTitleBottomSheet extends StatefulWidget {
  final List<Language>? languageList;
  final TabController? tabController;
  final List<TextEditingController>? nameControllerList;
  const GenerateTitleBottomSheet({super.key, this.nameControllerList, this.languageList, this.tabController});

  @override
  State<GenerateTitleBottomSheet> createState() => _GenerateTitleBottomSheetState();
}

class _GenerateTitleBottomSheetState extends State<GenerateTitleBottomSheet> {

  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<AiController>(context,listen: false).initializeKeyWords();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge),
          ),
        ),
        child: Consumer<AiController>(
          builder: (context, aiController, child) {
            return Column(mainAxisSize: MainAxisSize.min, children: [

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const SizedBox(width: 20),

              Container(
                height: 5, width: 35,
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.close, color: Theme.of(context).hintColor.withValues(alpha: 0.6), size: 22),
                ),
              ),
            ]),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text(getTranslated('great', context) ?? '', style: robotoBold.copyWith(color: Theme.of(context).textTheme.titleMedium?.color)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text( getTranslated('now_tell_me_which_product_you_want_to_create_just_type_it_simply_like', context) ?? '', style: robotoBold.copyWith(color: Theme.of(context).textTheme.titleMedium?.color)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Row(children: [
                    CircleAvatar(backgroundColor: Theme.of(context).hintColor, radius: 3),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: Text(getTranslated('enter_some_keywords_you_want_in_the_name', context) ?? '', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeSmall))),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Row(children: [
                    CircleAvatar(backgroundColor: Theme.of(context).hintColor, radius: 3),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: Text(getTranslated('or_you_can_give_related_title_we_will_generate_some_new_title_for_you', context) ?? '', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeSmall))),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text(getTranslated('feel_free_to_describe_it_your_own_way', context) ?? '', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeSmall)),
                  SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Row(children: [
                        Expanded(
                          flex: 8,
                          child: CustomTextFieldWidget(
                            hintText: getTranslated('enter_sample_keyword', context),
                            labelText: getTranslated('keyword', context),
                            controller: _titleController,
                            textInputAction : TextInputAction.done,
                            onFieldSubmit: (name){
                              if(name.isNotEmpty) {
                                aiController.setKeyWord(name);
                                _titleController.text = '';
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        Expanded(
                          flex: 2,
                          child: CustomButtonWidget(btnTxt: getTranslated('add', context), backgroundColor: Theme.of(context).primaryColor, onTap: (){
                            if(_titleController.text.isNotEmpty) {
                              aiController.setKeyWord(_titleController.text.trim());
                              _titleController.text = '';
                            }
                          }),
                        ),

                      ]),
                      SizedBox(height: aiController.keyWordList.isNotEmpty ? Dimensions.paddingSizeSmall : 0),

                      aiController.keyWordList.isNotEmpty ? SizedBox(
                        height: 40,
                        child: ListView.builder(
                          shrinkWrap: true, scrollDirection: Axis.horizontal,
                          itemCount: aiController.keyWordList.length,
                          itemBuilder: (context, index){
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(color: Theme.of(context).hintColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                              child: Center(child: Row(children: [

                                Text(aiController.keyWordList[index]!, style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                InkWell(onTap: () => aiController.removeKeyWord(index), child: Icon(Icons.clear, size: 18, color: Theme.of(context).hintColor)),

                              ])),
                            );
                          },
                        ),
                      ) : const SizedBox(),

                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  aiController.isLoading ? SizedBox() :
                  CustomButtonWidget(
                    isLoading: aiController.isLoading,
                    backgroundColor: Theme.of(context).primaryColor,
                    onTap: () {
                      if(aiController.keyWordList.isEmpty) {
                        showCustomSnackBarWidget(getTranslated('please_add_a_keyword_to_generate_food_name', context), context);
                      }else{
                        aiController.generateTitleSuggestions();
                      }
                    },
                    btnTxt: getTranslated('generate_food_name', context),
                  ),
                  SizedBox(height: !aiController.isLoading ? 0 : Dimensions.paddingSizeLarge),

                  !aiController.isLoading ? SizedBox() : Shimmer.fromColors(
                    baseColor: Theme.of(context).primaryColor,
                    highlightColor: Colors.grey[100]!,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.auto_awesome, color: Colors.blue),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      Text('${getTranslated('generating', context)}...', style: robotoBold.copyWith(color: Colors.blue)),
                    ]),
                  ),
                  SizedBox(height: aiController.titleSuggestionModel?.data?.titles != null && aiController.titleSuggestionModel!.data!.titles!.isNotEmpty ? Dimensions.paddingSizeLarge : 0),

                  aiController.titleSuggestionModel?.data?.titles != null && aiController.titleSuggestionModel!.data!.titles!.isNotEmpty ?
                  Text(getTranslated('suggested_food_name', context) ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)) : SizedBox(),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  aiController.titleSuggestionModel?.data?.titles != null && aiController.titleSuggestionModel!.data!.titles!.isNotEmpty ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: aiController.titleSuggestionModel?.data?.titles?.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          side: BorderSide(color: Theme.of(context).hintColor.withValues(alpha: 0.2), width: 0.5),
                        ),
                        child: ListTile(
                          title: Text(aiController.titleSuggestionModel?.data?.titles?[index] ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                          trailing: InkWell(
                            onTap: () {
                              widget.nameControllerList![widget.tabController!.index].text = aiController.titleSuggestionModel!.data!.titles![index];
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue, width: 1),
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [

                                Icon(CupertinoIcons.checkmark_rectangle, color: Colors.blue, size: 16),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                Text(getTranslated('use', context) ?? '', style: robotoRegular.copyWith(color: Colors.blue, fontSize: Dimensions.fontSizeSmall)),

                              ]),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                        ),
                      );
                    },
                  ) : SizedBox(),

                ]),
              ),
            ),
          ]);
          }
        ),
      ),
    );
  }
}
