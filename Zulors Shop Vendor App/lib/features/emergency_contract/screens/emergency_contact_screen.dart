import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/emergency_contract/controllers/emergency_contact_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_delegate_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_search_field_widget.dart';
import 'package:zulors_shop_vendor/features/emergency_contract/widgets/add_emergency_contact_widget.dart';
import 'package:zulors_shop_vendor/features/emergency_contract/widgets/emergency_contact_list_widget.dart';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    Provider.of<EmergencyContactController>(context, listen: false).toggleIsSearchActive(false, isUpdate: false);
    Provider.of<EmergencyContactController>(context, listen: false).getEmergencyContactList();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('emergency_contact', context),isBackButtonExist: true,),
      body: RefreshIndicator(
        onRefresh: () async{
        },
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(delegate: SliverDelegateWidget(
                height: 90,
                child : Consumer<EmergencyContactController>(
                  builder: (context, emergencyContactProvider, child) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault),
                      child: CustomSearchFieldWidget(
                        controller: searchController,
                        hint: getTranslated('search', context),
                        prefix: !emergencyContactProvider.isSearchActive ? Images.iconsSearch : Images.crossIcon,
                        iconPressed: () => () {
                          if(emergencyContactProvider.isSearchActive) {
                            emergencyContactProvider.toggleIsSearchActive(false);
                            searchController.text =  '';
                          } else {
                            emergencyContactProvider.toggleIsSearchActive(true);
                            emergencyContactProvider.getEmergencyContactListSearch(searchController.text);
                          }
                        },
                        onSubmit: (_) {
                          if(emergencyContactProvider.isSearchActive) {
                            emergencyContactProvider.toggleIsSearchActive(false);
                            searchController.text =  '';
                          } else {
                            emergencyContactProvider.toggleIsSearchActive(true);
                            emergencyContactProvider.getEmergencyContactListSearch(searchController.text);
                          }
                        },
                        onChanged: (value){

                        },
                        isFilter: false,
                      ),
                    );
                  }
                )
            )),
             const SliverToBoxAdapter(
              child: Column(
                children: [
                  EmergencyContactListViewWidget(),
                ],
              ),
            )
          ],
        ),),
      floatingActionButton:FloatingActionButton(
        backgroundColor: Theme.of(context).cardColor,
        child: Icon(Icons.add_circle, size: Dimensions.iconSizeExtraLarge,
          color: Theme.of(context).primaryColor,),
        onPressed: (){
          showDialog(context: context, builder: (_){
            return const AddEmergencyContactWidget();});
        },
      ) ,
    );
  }
}

