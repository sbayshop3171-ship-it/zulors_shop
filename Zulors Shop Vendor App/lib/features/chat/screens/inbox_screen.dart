import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/chat/widgets/inbox_shimmer_widget.dart';
import 'package:zulors_shop_vendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/chat/controllers/chat_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/no_data_screen.dart';
import 'package:zulors_shop_vendor/common/basewidgets/paginated_list_view_widget.dart';
import 'package:zulors_shop_vendor/features/chat/widgets/chat_card_widget.dart';
import 'package:zulors_shop_vendor/features/chat/widgets/chat_header_widget.dart';
import 'package:zulors_shop_vendor/utill/images.dart';

class InboxScreen extends StatefulWidget {
  final bool isBackButtonExist;
  final bool fromNotification;
  final int initIndex;
  const InboxScreen({super.key, this.isBackButtonExist = true, this.fromNotification = false, this.initIndex = 0});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final ScrollController _scrollController = ScrollController();

@override
  void initState() {
    if(widget.fromNotification) {
      Provider.of<ChatController>(context, listen: false).setUserTypeIndex(context, widget.initIndex, isUpdate: false);
    }

    Provider.of<ChatController>(context, listen: false).getChatList(context, 1, reload: true);

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
  final Size size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (canPop, _) async {
        if(widget.fromNotification) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const DashboardScreen()));
        }else {
          if(canPop) return;
          Navigator.of(context).pop();

        }
        return;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBarWidget(
          title: getTranslated('inbox', context),
          onBackPressed: () {
            if(widget.fromNotification) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const DashboardScreen()));
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        body: Consumer<ChatController>(builder: (context, chatProvider, child) {

          return Column(children: [

            Container(padding: const EdgeInsets.symmetric(vertical:Dimensions.paddingSizeExtraSmall),
                child:  const ChatHeaderWidget()),

            chatProvider.chatModel == null ?
            const InboxShimmerWidget() :
            (chatProvider.chatModel?.chat?.isNotEmpty ?? false) ?
            Expanded(
              child:  RefreshIndicator(
                onRefresh: () async {
                  chatProvider.getChatList(context,1);
                },
                child: Scrollbar(child: CustomScrollView(slivers: [
                  SliverToBoxAdapter(child: Center(child: SizedBox(width: 1170,
                    child: PaginatedListViewWidget(
                      reverse: false,
                      scrollController: _scrollController,
                      onPaginate: (int? offset) => chatProvider.getChatList(context,offset!, reload: false),
                      totalSize: chatProvider.chatModel!.totalSize,
                      offset: int.parse(chatProvider.chatModel!.offset!),
                      enabledPagination: chatProvider.chatModel == null,
                      itemView: ListView.builder(
                        itemCount: chatProvider.chatModel!.chat!.length,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ChatCardWidget(
                            chat: chatProvider.chatModel!.chat![index],
                            callBack: (){
                              chatProvider.updateMessageSeen(index);
                            },
                          );
                        },
                      ),
                    ),
                  )),)
                ])),
              ),
            ) :
            Expanded(child: NoDataScreen(
              padding: EdgeInsets.only(top: size.height * 0.15),
              title: chatProvider.userTypeIndex == 0 ? 'no_customer_found' : 'no_deliveryman_found',
              image: chatProvider.userTypeIndex == 0 ? Images.noCustomerPlaceHolder : Images.deliverymanPlaceHolder,
            )),
          ]);
        }),
      ),
    );
  }
}



